require 'ib'
require_relative '../../config/interactive_brokers'

module MyTradeWizard
  class InteractiveBrokers

    def connect(timeout = nil)
      start_time = Time.now
      exception = nil
      while (timeout.nil? || Time.now - start_time <= timeout)
        begin
          @ib = IB::Connection.new :host => self.class.host, :port => self.class.port
          subscribe_to_alerts
          return @ib
        rescue Exception => exception
          puts exception
          sleep 10
        end
      end
      raise exception
    end

    def accounts
      a = nil
      @ib.subscribe(:ManagedAccounts) { |msg| a = msg.accounts_list.split(',') }
      while a.nil?
        sleep 1
      end
      a
    end

    def front_month(symbol)
      expiry = MyTradeWizard::CME.first_month(symbol)
      if invalid contract(symbol, expiry)
        expiry = MyTradeWizard::CME.second_month(symbol)
        if invalid contract(symbol, expiry)
          raise ErrorDeterminingFrontMonth
        end
      end
      expiry
    end

  private

    def subscribe_to_alerts
      @ib.subscribe(:Alert, :ReceiveFA, :OpenOrder, :OrderStatus, :ExecutionData, :CommissionReport, :ManagedAccounts) do |msg|
        #puts msg.to_human unless msg.to_human.include?("No security definition has been found for the request")
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
      @ib.subscribe(:ContractData, :ContractDataEnd) { |msg| valid = true }
      @ib.send_message :RequestContractData, :id => 1, :contract => contract
      @ib.wait_for :ContractDataEnd, 5
      @ib.clear_received :ContractDataEnd
      valid
    end

    def invalid(contract)
      !valid(contract)
    end

  end
end