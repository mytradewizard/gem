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

    def actionize(signal)
      @action = MyTradeWizard::Action.new(signal)
    end

    def action
      @action
    end

    def place_orders(open_time, close_time)
      unless @action.nil?
        @ib.place_market_orders(@account, @action, @quantity, @contract, open_time, close_time)
      end
    end

  end
end