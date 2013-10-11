module MyTradeWizard
  class TradingSystem

    include MyTradeWizard::DateTime
    include MyTradeWizard::TechnicalIndicator

    def initialize
      @ib = MyTradeWizard::InteractiveBrokers.new
      @ib_ruby = @ib.connect
      @environment = MyTradeWizard::Configuration::ENVIRONMENT
      @account = MyTradeWizard::Configuration::InteractiveBrokers::ACCOUNT.empty? ? @ib.accounts.first : MyTradeWizard::Configuration::InteractiveBrokers::ACCOUNT
      @logger = Logger.new("/mtw/sys/#{self.class.to_s.downcase}/log/#{Time.now.strftime('%Y%m%d-%H%M')}") unless test?
      @email = MyTradeWizard::Email.new
      @email.subject = (production?) ? self.class.to_s : "#{@environment.upcase} #{self.class.to_s}"
      @email.body = ""
      @orders = []
    end

    def positions
      @positions = @ib.positions(@account)
    end

    def place_market_order(action, quantity, contract)
      @ib.place_market_order(@account, action, quantity, contract)
    end

    def output(msg)
      if @logger.present?
        @logger.info msg
      else
        puts msg
      end
    end

    def email(msg = nil)
      if msg.nil?
        return @email
      else
        @email.body = msg
        @email.send
      end
    end

    def test?
      @environment == 'local'
    end

    def production?
      @environment == 'production'
    end

  end
end