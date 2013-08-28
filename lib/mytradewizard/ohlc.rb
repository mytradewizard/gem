module MyTradeWizard
  class OHLC
    def initialize(hash)
      @hash = hash
    end
    def open
      @hash['Open']
    end
    def high
      @hash['High']
    end
    def low
      @hash['Low']
    end
    def close
      @hash['Close']
    end
  end
end