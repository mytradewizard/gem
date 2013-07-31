require 'mytradewizard'

describe MyTradeWizard::InteractiveBrokers do

  it "connects to Interactive Brokers" do
    ib = MyTradeWizard::InteractiveBrokers.new
    expect { ib.connect(60) }.to_not raise_error
  end

end