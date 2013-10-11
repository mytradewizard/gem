require 'gmail'

module MyTradeWizard
  class Email

    attr_accessor :subject
    attr_accessor :body

    def <<(msg)
      @body << msg << "\n"
    end

    def send
      to = MyTradeWizard::Configuration::Email::TO
      subject = @subject
      body = @body
      username = MyTradeWizard::Configuration::Email::GMAIL_USERNAME
      password = MyTradeWizard::Configuration::Email::GMAIL_PASSWORD
      unless to.empty? || username.empty? || password.empty?
        Gmail.connect!(username, password) do |gmail|
          gmail.deliver! do
            to(to)
            subject(subject)
            body(body)
          end
        end
      end
    end

  end
end