require 'ib'

module MyTradeWizard
  class InteractiveBrokers

    attr_reader :accounts

    def connect(timeout = nil)
      puts "Connecting to IB..."
      start_time = Time.now
      exception = nil
      while (timeout.nil? || Time.now - start_time <= timeout)
        begin
          @ib_ruby = IB::Connection.new :host => MyTradeWizard::Configuration::InteractiveBrokers::HOST, :port => MyTradeWizard::Configuration::InteractiveBrokers::PORT
          subscribe_to_alerts
          sleep 0.1
          fetch_accounts
          return @ib_ruby
        rescue Exception => exception
          puts exception
          sleep 10
        end
      end
      raise exception
    end

    def daily_bars(contract, days, confirm = true)
      puts "Fetching daily bars..."
      bars = nil   
      @ib_ruby.subscribe(IB::Messages::Incoming::HistoricalData) { |msg| bars = msg.results }
      @ib_ruby.send_message IB::Messages::Outgoing::RequestHistoricalData.new(
                                :request_id => 123,
                                :contract => contract,
                                :end_date_time => Time.now.utc.to_ib,
                                :duration => "#{days} D",
                                :bar_size => '1 day',
                                :what_to_show => :trades,
                                :use_rth => 1,
                                :format_date => 1)
      while bars.nil?
        sleep 1
      end
      if confirm && bars.size < days
        raise "Invalid Data!  (#{bars.size}/#{days} valid bars.)"
      else
        bars.reverse!
        puts bars
        return bars
      end
    end

    def hourly_bars(contract, hourly_range, confirm = true)
      range_size = hourly_range.last - hourly_range.first
      puts "Fetching hourly bars..."
      bars = nil
      @ib_ruby.subscribe(IB::Messages::Incoming::HistoricalData) { |msg| bars = msg.results }
      @ib_ruby.send_message IB::Messages::Outgoing::RequestHistoricalData.new(
                            :request_id => 123,
                            :contract => contract,
                            :end_date_time => Time.now.utc.to_ib,
                            :duration => "#{60*60*range_size} S",
                            :bar_size => '1 hour',
                            :what_to_show => :trades,
                            :use_rth => 0,
                            :format_date => 1)
      while bars.nil?
        sleep 1
      end
      if confirm
        bars.keep_if { |bar| Time.parse(bar.time).wday == Time.now.utc.wday && hourly_range.include?(Time.parse(bar.time).hour) }
        if bars.size == range_size
          puts bars
          return bars
        else
          raise "Invalid Data!  (#{bars.size}/#{range_size} valid bars.)"
        end
      else
        puts bars
        return bars
      end   
    end

    def positions(account)
      p = Array.new
      @ib_ruby.subscribe(:Alert, :AccountValue, :PortfolioValue, :AccountUpdateTime, :AccountDownloadEnd) do |msg|
        if msg.message_type == :PortfolioValue
          if msg.contract.sec_type == :stock
            stock = MyTradeWizard::Stock.new(msg.contract.symbol)
            size = msg.position
            p << MyTradeWizard::Position.new(stock, size)
          end
        end
      end
      @ib_ruby.send_message :RequestAccountData, :subscribe => true, :account_code => account
      @ib_ruby.wait_for :AccountDownloadEnd
      @ib_ruby.send_message :RequestAccountData, :subscribe => false, :account_code => account
      @ib_ruby.received[:AccountDownloadEnd].clear
      p
    end

    def buying_power(account)
      buying_power = nil
      @ib_ruby.subscribe(:Alert, :AccountValue, :PortfolioValue, :AccountUpdateTime, :AccountDownloadEnd) do |msg|
        if msg.message_type == :AccountValue
          if msg.data[:key] == "BuyingPower"
            buying_power = msg.data[:value]
          end
        end
      end
      @ib_ruby.send_message :RequestAccountData, :subscribe => true, :account_code => account
      @ib_ruby.wait_for :AccountDownloadEnd
      @ib_ruby.send_message :RequestAccountData, :subscribe => false, :account_code => account
      @ib_ruby.received[:AccountDownloadEnd].clear
      buying_power.to_f
    end

    def place_market_order(account, action, quantity, contract)
      order = IB::Order.new :total_quantity => quantity,
                            :action => action.to_s,
                            :order_type => 'MKT',
                            :tif => 'OPG',
                            :account => account
      @ib_ruby.wait_for :NextValidId
      @ib_ruby.place_order order, contract
      #puts "#{action} #{quantity} #{contract.symbol}"
    end

    def place_market_order_between(account, action, quantity, contract, good_after, good_till)
      order = IB::Order.new :total_quantity => quantity,
                            :action => action.to_s,
                            :order_type => 'MKT',
                            :good_after_time => good_after,
                            :good_till_date => good_till,
                            :tif => 'GTD',
                            :account => account
      @ib_ruby.wait_for :NextValidId
      @ib_ruby.place_order order, contract
      puts "#{action} #{quantity} #{contract.symbol} @ #{good_after}"
    end

    def place_market_orders(account, action, quantity, contract, open_time, close_time)
      good_after_open = Time.parse(open_time).strftime("%Y%m%d %H:%M:%S %Z")
      good_till_open = (Time.parse(open_time) + 60).strftime("%Y%m%d %H:%M:%S %Z")
      good_after_close = Time.parse(close_time).strftime("%Y%m%d %H:%M:%S %Z")
      good_till_close = (Time.parse(close_time) + 60).strftime("%Y%m%d %H:%M:%S %Z")
      if quantity.is_a? Fixnum
        place_market_order_between(account, action, quantity, contract, good_after_open, good_till_open)
        @ib_ruby.subscribe(:OrderStatus, :OpenOrderEnd) do |msg|
          if msg.message_type == :OrderStatus
            if msg.status == 'Submitted'
              place_market_order_between(account, action.reverse, quantity, contract, good_after_close, good_till_close)
            elsif msg.status == 'Cancelled'
              puts "CANCELLED: #{action} #{quantity} #{contract.symbol} @ #{open_time}"
            end
          end
        end
        @ib_ruby.send_message :RequestAllOpenOrders
        @ib_ruby.wait_for :OrderStatus
      elsif quantity.is_a? Range
        quantity.each do |q|
          if q == quantity.first
            place_market_order_between(account, action, q, contract, good_after_open, good_till_open)
            @ib_ruby.subscribe(:OrderStatus, :OpenOrderEnd) do |msg|
              if msg.message_type == :OrderStatus
                if msg.status == 'Submitted'
                  place_market_order_between(account, action.reverse, q, contract, good_after_close, good_till_close)
                elsif msg.status == 'Cancelled'
                  puts "CANCELLED: #{action} #{q} #{contract.symbol} @ #{open_time}"
                  break
                end
              end
            end
            @ib_ruby.send_message :RequestAllOpenOrders, :subscribe => true, :account_code => account
            @ib_ruby.wait_for :OrderStatus
            @ib_ruby.send_message :RequestAllOpenOrders, :subscribe => false, :account_code => account
            @ib_ruby.received[:OrderStatus].clear
          else
            place_market_order_between(account, action, 1, contract, good_after_open, good_till_open)
            @ib_ruby.subscribe(:OrderStatus, :OpenOrderEnd) do |msg|
              if msg.message_type == :OrderStatus
                if msg.status == 'Submitted'
                  place_market_order_between(account, action.reverse, 1, contract, good_after_close, good_till_close)
                elsif msg.status == 'Cancelled'
                  puts "CANCELLED: #{action} 1 #{contract.symbol} @ #{open_time}"
                  break
                end
              end
            end
            @ib_ruby.send_message :RequestAllOpenOrders, :subscribe => true, :account_code => account
            @ib_ruby.wait_for :OrderStatus
            @ib_ruby.send_message :RequestAllOpenOrders, :subscribe => false, :account_code => account
            @ib_ruby.received[:OrderStatus].clear
          end
        end
      end
    end

    def front_month(symbol)
      expiry = MyTradeWizard::CME.first_month(symbol)
      if invalid contract(symbol, expiry)
        expiry = MyTradeWizard::CME.second_month(symbol)
        if invalid contract(symbol, expiry)
          raise 'ErrorDeterminingFrontMonth'
        end
      end
      contract(symbol, expiry)
    end

  private

    def subscribe_to_alerts
      @ib_ruby.subscribe(:Alert, :ReceiveFA, :OpenOrder, :OrderStatus, :ExecutionData, :CommissionReport, :ManagedAccounts) do |msg|
        unless [:Alert, :ManagedAccounts].include? msg.message_type
          unless msg.to_human.include?("No security definition has been found for the request")
            puts msg.to_human
          end
        end
      end
    end

    def fetch_accounts
      puts "Fetching accounts...  "
      @accounts = nil
      @ib_ruby.subscribe(:ManagedAccounts) { |msg| @accounts = msg.accounts_list.split(',') }
      @ib_ruby.send_message :RequestManagedAccounts
      while @accounts.nil?
        sleep 1
      end
    end

    def CL(expiry)
      IB::Contract.new(:symbol => "CL", :expiry => expiry, :exchange => "NYMEX", :currency => "USD", :sec_type => :future, :description => "Crude future")
    end

    def QM(expiry)
      IB::Contract.new(:symbol => "QM", :expiry => expiry, :exchange => "NYMEX", :currency => "USD", :sec_type => :future, :description => "Mini-Crude future")
    end

    def contract(symbol, expiry)
      if symbol == :CL
        CL(expiry)
      elsif symbol == :QM
        QM(expiry)
      end
    end

    def valid(contract)
      valid = false
      @ib_ruby.subscribe(:ContractData, :ContractDataEnd) { |msg| valid = true }
      @ib_ruby.send_message :RequestContractData, :id => 1, :contract => contract
      @ib_ruby.wait_for :ContractDataEnd, 5
      @ib_ruby.clear_received :ContractDataEnd
      valid
    end

    def invalid(contract)
      !valid(contract)
    end

  end
end