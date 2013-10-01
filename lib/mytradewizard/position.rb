module MyTradeWizard
  class Position

    attr_reader :stock
    attr_reader :size

    def initialize(stock, size)
      @stock = stock
      @size = size
    end

  end
end