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
    #def sign
    #  return 1 if close > open
    #  return -1 if close < open
    #  return 0 if close == open
    #end
  end
end