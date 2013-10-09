module MyTradeWizard
  class TradingSystem

    include MyTradeWizard::DateTime
    include MyTradeWizard::TechnicalIndicator

    def initialize
      @ib = MyTradeWizard::InteractiveBrokers.new
      @ib_ruby = @ib.connect
      @live = false
      @account = @ib.accounts.first
      #fetch_positions
      @orders = []
    end

    def account=(a)
      @account = a
      make_live
    end

    def positions
      @positions = @ib.positions(@account)
    end

    def place_market_order(action, quantity, contract)
      @ib.place_market_order(@account, action, quantity, contract)
    end

    def make_live
      @live = true
      @logger = Logger.new("/mtw/log/#{self.class}/#{Time.now.strftime('%Y%m%d-%H%M')}.log")
      #fetch_positions
    end

    def at(hour, minute)
      wait_until(hour, minute) if @live
    end

    def idle(seconds)
      sleep(seconds) if @live
    end

    def output(msg)
      if @logger.present?
        @logger.info msg
      else
        puts msg
      end
    end

    def test?
      !@live
    end

  end
end