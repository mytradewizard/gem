require 'mytradewizard'

module MyTradeWizard
  class StockTradingSystem < MyTradeWizard::TradingSystem

    include MyTradeWizard::WatchLists

    attr_accessor :watchlist
    attr_writer :position_size

    def initialize
      super
      @watchlist = MyTradeWizard::WatchList.new
      #@position_size = 5000
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

    def buy(stock)
      order = MyTradeWizard::Order.new
      order.action = MyTradeWizard::Action.new("BUY")
      order.stock = stock
      return order
    end

    def sell(position)
      email << "SELL #{position.size} #{position.stock.symbol}"
      place_market_order "SELL", position.size, position.stock.contract
    end

    def place(orders)
      total_buying_power = @ib.buying_power(@account)
      buying_power_per_order = total_buying_power / orders.length
      orders.each do |order|
        order.quantity = (buying_power_per_order / order.stock.price).floor
        email << "#{order.action} #{order.quantity} #{order.stock.symbol}"
        place_market_order order.action.to_s, order.quantity, order.stock.contract
      end
      email.send
    end

  end
end