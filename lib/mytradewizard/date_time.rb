module MyTradeWizard
  module DateTime

    HR = 360

    def at(hour, minute)
      unless MyTradeWizard::Configuration::ENVIRONMENT == 'local'
        print "Waiting until #{hour}:#{minute} ..."    
        until time_is(hour, minute)
          sleep 60
          print '.'
        end
      end
    end

    def idle(seconds)
      sleep(seconds) unless MyTradeWizard::Configuration::ENVIRONMENT == 'local'
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