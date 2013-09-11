module MyTradeWizard
  class TradingSystem

    def initialize
      @ib = MyTradeWizard::InteractiveBrokers.new
      @ib_ruby = @ib.connect
    end

  end
end