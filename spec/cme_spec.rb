require 'mytradewizard'
require 'spec_helper'

describe MyTradeWizard::CME do

  it "returns the first tradable month for Crude according to the CME Group product calendar" do
    [month(0), month(1), month(2)].should include MyTradeWizard::CME.first_month(:CL)
  end

  it "returns the second tradable month for Crude according to the CME Group product calendar" do
    [month(1), month(2), month(3)].should include MyTradeWizard::CME.second_month(:CL)
  end

  it "returns the first tradable month for Mini-Crude according to the CME Group product calendar" do
    [month(0), month(1), month(2)].should include MyTradeWizard::CME.first_month(:QM)
  end

  it "returns the second tradable month for Mini-Crude according to the CME Group product calendar" do
    [month(1), month(2), month(3)].should include MyTradeWizard::CME.second_month(:QM)
  end

end