require 'mytradewizard'

module MyTradeWizard
  class FutureTradingSystem < MyTradeWizard::TradingSystem

    attr_writer :quantity

    def initialize
      super
      @quantity = 0
      @action = nil
    end

    def symbol=(s)
      @contract = @ib.front_month(s)
      puts @contract
    end

    def hours(hourly_range)
      @ib.hourly_bars(@contract, hourly_range, @live)
    end

    def place_opening_trade_between(good_after, good_till)
      unless @action.nil?
        print "Opening trade: "
        @ib.place_market_order(@account, @action, @quantity, @contract, good_after, good_till)
      end
    end

    def place_closing_trade_between(good_after, good_till)
      unless @action.nil?
        print "Closing trade: "
        @ib.place_market_order(@account, @action.reverse, @quantity, @contract, good_after, good_till)
      end
    end

  end
end