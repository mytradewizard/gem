require 'ib'
begin
  require "#{Dir.pwd}/config/interactive_brokers"
rescue LoadError
  puts "Please configure Interactive Brokers!"
end

module MyTradeWizard
  class InteractiveBrokers

    attr_reader :accounts

    def connect(timeout = nil)
      puts "Connecting to IB..."
      start_time = Time.now
      exception = nil
      while (timeout.nil? || Time.now - start_time <= timeout)
        begin
          @ib_ruby = IB::Connection.new :host => self.class.host, :port => self.class.port
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
      @ib_ruby.subscribe(:AccountValue, :PortfolioValue, :AccountUpdateTime, :AccountDownloadEnd) do |msg|
        if msg.message_type == :PortfolioValue
          if msg.contract.sec_type == :stock
            stock = MyTradeWizard::Stock.new(msg.contract.symbol)
            p << stock
          end
        end
      end
      @ib_ruby.send_message :RequestAccountData, :account_code => account
      p
    end

    def place_market_order(account, action, quantity, contract, good_after, good_till)
      order = IB::Order.new :total_quantity => quantity,
                            :action => action.to_s,
                            :order_type => 'MKT',
                            :good_after_time => "#{Time.now.utc.strftime('%Y%m%d')} #{good_after}",
                            :good_till_date => "#{Time.now.utc.strftime('%Y%m%d')} #{good_till}",
                            :tif => 'GTD',
                            :account => account
      @ib_ruby.wait_for :NextValidId
      @ib_ruby.place_order order, contract
      puts "#{action} #{quantity} #{contract.symbol} @ #{good_after}"
    end

    def front_month(symbol)
      expiry = MyTradeWizard::CME.first_month(symbol)
      if invalid contract(symbol, expiry)
        expiry = MyTradeWizard::CME.second_month(symbol)
        if invalid contract(symbol, expiry)
          raise ErrorDeterminingFrontMonth
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