require 'mytradewizard'

module MyTradeWizard
  class StockTradingSystem < MyTradeWizard::TradingSystem

    include MyTradeWizard::WatchLists

    attr_accessor :watch_list
    attr_writer :position_size

    def initialize
      super
      @watch_list = MyTradeWizard::WatchList.new
      @position_size = 5000
      @data = nil
    end

    def preload(days, stock)
      @stock = stock
      @data = MyTradeWizard::Yahoo.OHLC(stock.symbol, days)
      if @data.length < days
        puts "ERROR: Only #{@data.length}/#{days} days of data for #{stock.symbol}"
      end
    end

    def t
      @data.today
    end

    def days(daily_range)
      @data.days(daily_range)
    end

    def close(day)
      @data.day(day).close
    end

    def buy
      place_market_order "BUY", @position_size/close(t).floor, @stock.contract
    end

    def sell(position)
      place_market_order "SELL", position.size, @stock.contract
    end

  end
end