module MyTradeWizard
  module Configuration
    ENV = "<%= env %>"
    EMAIL = "<%= email %>"
    module InteractiveBrokers
      HOST = "<%= host %>"
      PORT = <%= port %>
      ACCOUNT = "<%= account %>"
    end
  end
end