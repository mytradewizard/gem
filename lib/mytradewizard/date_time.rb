module MyTradeWizard
  class DateTime
    class << self

      def WaitUntil(hour, minute)
        print "Waiting until #{hour}:#{minute} ..."    
        until time_is(hour, minute)
          sleep 60
          print '.'
        end
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
end