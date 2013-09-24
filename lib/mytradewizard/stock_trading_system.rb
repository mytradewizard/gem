require 'mytradewizard'

module MyTradeWizard
  class StockTradingSystem < MyTradeWizard::TradingSystem

    attr_reader :watch_list

    def initialize
      super
      @watch_list = MyTradeWizard::WatchList.new
      @data = nil
    end

    def preload(stock, days)
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

  end
end