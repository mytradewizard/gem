require 'nokogiri'
require 'open-uri'

module MyTradeWizard
  class CME
    class << self

      def first_month(symbol)
        product_calendar(symbol, 3)
      end

      def second_month(symbol)
        product_calendar(symbol, 4)
      end

    private

      def product_calendar(symbol, row)
        if symbol == :CL
          url = 'http://www.cmegroup.com/trading/energy/crude-oil/light-sweet-crude_product_calendar_futures.html'
        elsif symbol == :QM
          url = 'http://www.cmegroup.com/trading/energy/crude-oil/emini-crude-oil_product_calendar_futures.html'
        end
      
        doc = Nokogiri::HTML(open(url))

        mmm_yyyy = doc.xpath("//table[@class='ProductTable']/tr[#{row}]/td[1]/text()").to_s
        yyyy = mmm_yyyy[-4,4]
        mmm = mmm_yyyy[0,3]

        case mmm
        when 'JAN'
          mm = '01'
        when 'FEB'
          mm = '02'
        when 'MAR'
          mm = '03'
        when 'APR'
          mm = '04'
        when 'MAY'
          mm = '05'
        when 'JUN'
          mm = '06'
        when 'JUL'
          mm = '07'
        when 'AUG'
          mm = '08'
        when 'SEP'
          mm = '09'
        when 'OCT'
          mm = '10'
        when 'NOV'
          mm = '11'
        when 'DEC'
          mm = '12'
        else
          raise "Invalid month"
        end

        yyyy + mm
      end

    end
  end
end