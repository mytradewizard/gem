module MyTradeWizard
  class WatchList

    attr_accessor :stocks

    def initialize
      @stocks = []
    end

    def <<(stock)
      @stocks << stock
    end

  end
end