require 'ib'

module MyTradeWizard
  class Stock

    attr_reader :symbol
    attr_reader :contract

    def initialize(symbol)
      @symbol = symbol
      @contract = IB::Contract.new(:sec_type => :stock, :symbol => symbol, :currency => "USD")
    end

    def ==(other)
      other.class == self.class && other.symbol == symbol
    end

    def price
      MyTradeWizard::Yahoo.OHLC(symbol, 1).most_recent.close
    end

  end
end