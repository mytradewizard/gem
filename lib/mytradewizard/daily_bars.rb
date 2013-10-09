module MyTradeWizard
  class DailyBars

    def initialize
      @hash = Hash.new
    end

    def length
      @hash.length
    end

    def add(day, bar)
      @hash[day] = bar
    end

    def today
      @hash.keys.max
    end

    def most_recent
      @hash[today]
    end

    def day(day)
      @hash[day]
    end

    def days(daily_range)
      @hash.select { |day, bar| daily_range.begin <= day && day <= daily_range.end }.values
    end

  end
end