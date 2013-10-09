module MyTradeWizard
  class Action

    def initialize(signal)
      case signal
      when "BUY"
        @signal = 1
      when "SELL"
        @signal = -1
      else
        @signal = signal
      end
    end

    def to_s
      if @signal > 0
        return "BUY"
      elsif @signal < 0
        return "SELL"
      else
        return "None"
      end
    end

    def reverse!
      @signal = -@signal
      return self
    end

    def reverse
      return MyTradeWizard::Action.new(-@signal)
    end

    def nil?
      @signal == 0
    end

  end
end