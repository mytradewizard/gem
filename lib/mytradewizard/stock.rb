require 'ib'

module MyTradeWizard
  class Stock

    attr_reader :symbol
    attr_reader :contract

    def initialize(symbol)
      @symbol = symbol
      @contract = IB::Contract.new(:sec_type => :stock, :symbol => symbol, :currency => "USD")
    end

  end
end