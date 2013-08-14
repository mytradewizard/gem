require 'ib'

module MyTradeWizard
  class Stock

    def initialize(symbol)
      IB::Contract.new(:sec_type => :stock, :symbol => symbol)
    end

  end
end