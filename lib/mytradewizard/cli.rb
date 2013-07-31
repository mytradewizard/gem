require 'thor'
require 'mytradewizard'
require 'mytradewizard/generators/interactive_brokers'

module MyTradeWizard
  class CLI < Thor

    desc "configure [-- host HOST] [-- port PORT]", "Generate Interactive Brokers configuration"
    method_options :host => :string, :port => :numeric
    def configure
      MyTradeWizard::Generators::InteractiveBrokers.start([options[:host] || "localhost", options[:port] || 7496])
    end

    desc "config", "Display Interactive Brokers configuration"
    def config
      puts "Host: " + MyTradeWizard::InteractiveBrokers.host
      puts "Port: " + MyTradeWizard::InteractiveBrokers.port.to_s
    end

    desc "connect", "Connects to Interactive Brokers"
    def connect
      ib = MyTradeWizard::InteractiveBrokers.new
      ib.connect
    end

    desc "accounts", "Lists Interactive Brokers accounts"
    def accounts
      ib = MyTradeWizard::InteractiveBrokers.new
      ib.connect
      puts "Accounts: " + ib.accounts.join(", ")
    end

    desc "CL", "Determines the front month Crude future contract"
    def CL
      ib = MyTradeWizard::InteractiveBrokers.new
      ib.connect
      puts "Front month: " + ib.front_month(:CL)
    end

    desc "QM", "Determines the front month Mini-Crude future contract"
    def QM
      ib = MyTradeWizard::InteractiveBrokers.new
      ib.connect
      puts "Front month: " + ib.front_month(:QM)
    end

  end
end