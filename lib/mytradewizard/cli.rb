require 'thor'
require 'mytradewizard'
require 'mytradewizard/generators/mytradewizard'

module MyTradeWizard
  class CLI < Thor

    desc "configure [-- env ENV] [-- email EMAIL] [-- host HOST] [-- port PORT] [-- account ACCOUNT]", "Generate Interactive Brokers configuration"
    method_options :env => :string, :email => :string, :host => :string, :port => :numeric, :account => :string
    def configure
      MyTradeWizard::Generators::MyTradeWizard.start([options[:env] || "local", options[:email] || "", options[:host] || "localhost", options[:port] || 7496, options[:account] || ""])
    end

    desc "config", "Display Interactive Brokers configuration"
    def config
      puts "Env: " + MyTradeWizard::Configuration::ENV
      puts "Email: " + MyTradeWizard::Configuration::EMAIL
      puts "Host: " + MyTradeWizard::Configuration::InteractiveBrokers::HOST
      puts "Port: " + MyTradeWizard::Configuration::InteractiveBrokers::PORT.to_s
      puts "Account: " + MyTradeWizard::Configuration::InteractiveBrokers::ACCOUNT
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
      puts "Front month: " + ib.front_month(:CL).expiry
    end

    desc "QM", "Determines the front month Mini-Crude future contract"
    def QM
      ib = MyTradeWizard::InteractiveBrokers.new
      ib.connect
      puts "Front month: " + ib.front_month(:QM).expiry
    end

  end
end