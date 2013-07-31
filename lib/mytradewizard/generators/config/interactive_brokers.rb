module MyTradeWizard
  class InteractiveBrokers
    class << self
      def host
        "<%= host %>"
      end
      def port
        <%= port %>
      end
    end
  end
end