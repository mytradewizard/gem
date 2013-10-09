module MyTradeWizard
  class WatchList

    attr_accessor :stocks

    def initialize(stocks = [])
      @stocks = []
      self << stocks
    end

    def <<(x)
      if x.is_a?(MyTradeWizard::Stock)
        @stocks << x
      elsif x.is_a?(Array) && x.first.is_a?(MyTradeWizard::Stock)
        x.each { |stock| @stocks << stock }
      elsif x.is_a?(String)
        @stocks << MyTradeWizard::Stock.new(x)
      elsif x.is_a?(Array) && x.first.is_a?(String)
        x.each { |symbol| @stocks << MyTradeWizard::Stock.new(symbol) }
      end
    end

    def each(&block)
      @stocks.each(&block)
    end

    def remove(positions)
      @stocks.reject { |stock| positions.any? { |position| position.stock == stock } }
    end

  end
end