module MyTradeWizard
  class TradingSystem

    include MyTradeWizard::DateTime
    include MyTradeWizard::TechnicalIndicator

    def initialize
      @ib = MyTradeWizard::InteractiveBrokers.new
      @ib_ruby = @ib.connect
      @env = MyTradeWizard::Configuration::ENV
      @account = MyTradeWizard::Configuration::InteractiveBrokers::ACCOUNT.empty? ? @ib.accounts.first : MyTradeWizard::Configuration::InteractiveBrokers::ACCOUNT
      @logger = Logger.new("/mtw/sys/#{self.class.to_s.downcase}/log/#{Time.now.strftime('%Y%m%d-%H%M')}") unless test?
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

    def test?
      @env == 'local'
    end

  end
end