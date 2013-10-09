require 'open-uri'
require 'csv'
require 'active_support/time'

module MyTradeWizard
  class Yahoo
    class << self

      def OHLC(symbol, days, end_date = Date.today)
        sd = start_date(end_date, days)
        u = url(symbol, sd.month - 1, sd.day, sd.year, end_date.month, end_date.day, end_date.year, 'd')
        csv = CSV.parse(open(u))
        header = csv.first
        if (Date.parse(csv[1][0]) == end_date)
          day = 0
        else
          day = -1
        end
        row = 1
        daily_bars = MyTradeWizard::DailyBars.new
        while (daily_bars.length < days)
          bar = Hash.new
          csv[row].each_with_index do |col, i|
            name = header[i]
            value = csv[row][i]
            if name == "Date"
              value = Date.parse(value)
            elsif ["Open", "High", "Low", "Close", "Adj Close"].include?(name)
              value = value.to_f
            elsif name == "Volume"
              value = value.to_i
            end
            bar[name] = value
          end
          daily_bars.add(day, MyTradeWizard::OHLC.new(bar))
          row += 1
          day -= 1
        end
        daily_bars
      end

    private
      
      def start_date(end_date, n)
        end_date - (2*n+1).days
      end
      
      def url(symbol, start_month, start_day, start_year, end_month, end_day, end_year, frequency)
        symbol = symbol.gsub(" ", "-")
        query_string = "?s=#{symbol}&a=#{start_month}&b#{start_day}&c=#{start_year}&d=#{end_month}&e=#{end_day}&f=#{end_year}&g=#{frequency}"
        url = 'http://ichart.finance.yahoo.com/table.csv' + query_string
      end

    end
  end
end