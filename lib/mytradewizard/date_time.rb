module MyTradeWizard
  module DateTime

    HR = 360

    def wait_until(hour, minute)
      print "Waiting until #{hour}:#{minute} ..."    
      until time_is(hour, minute)
        sleep 60
        print '.'
      end
    end

    def friday
      Time.now.utc.wday == 5
    end

    private

    def time_is(hour, minute)
      if (1..5).include?(Time.now.utc.wday)
        if Time.now.utc.hour == hour
          if Time.now.utc.min >= minute
            return true
          end
        end
      end
      false
    end

  end
end