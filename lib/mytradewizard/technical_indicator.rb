module MyTradeWizard
  module TechnicalIndicator

      def SMA(bars)
        x = 0
        n = 0
        bars.each do |bar|
          x += bar.close
          n += 1
        end
        return x / n
      end

  end
end