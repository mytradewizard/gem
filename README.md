# mytradewizard gem

This gem provides a Ruby and Command Line Interface for the Interactive Brokers API.

## Installation

Add this line to your application's Gemfile:

    gem 'mytradewizard'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mytradewizard

## Usage

By default, mytradewizard assumes that the Interactive Brokers Trader Workstation is running on localhost port 7496.  To configure hostname and/or port:

    $ mtw configure [-- host HOST] [-- port PORT]

You can always display current configuration:

    $ mtw config

To begin, it is recommended that you test the connection:

    $ mtw connect

Then you can display a list of accounts:

    $ mtw accounts

Determine front month Crude:

    $ mtw CL

Or Mini-Crude:

    $ mtw QM

To do the same from a ruby program:

    require 'mytradewizard'
    ib = MyTradeWizard::InteractiveBrokers.new
    ib.connect(60) # optional 60 second timeout
    ib.accounts
    ib.front_month(:CL)
    ib.front_month(:QM)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
