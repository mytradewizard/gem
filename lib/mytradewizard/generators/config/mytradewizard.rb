module MyTradeWizard
  module Configuration
    ENVIRONMENT = "<%= environment %>"
    module InteractiveBrokers
      HOST = "<%= host %>"
      PORT = <%= port %>
      ACCOUNT = "<%= account %>"
    end
    module Email
      TO = "<%= email_to %>"
      GMAIL_USERNAME = "<%= gmail_username %>"
      GMAIL_PASSWORD = "<%= gmail_password %>"
    end
  end
end