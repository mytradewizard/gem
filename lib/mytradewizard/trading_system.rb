module MyTradeWizard
  class TradingSystem

    include MyTradeWizard::DateTime
    include MyTradeWizard::TechnicalIndicator

    def initialize
      @ib = MyTradeWizard::InteractiveBrokers.new
      @ib_ruby = @ib.connect
      @live = false
      @account = @ib.accounts.first
      fetch_positions
    end

    def account=(a)
      @live = true
      @account = a
      fetch_positions
    end

    def fetch_positions
      @positions = @ib.positions(@account)
    end

  end
end