Feature: Interactive Brokers configuration
	In order to generate and display Interactive Brokers configuration
	As a CLI
	I want My Trade Wizard to create and use a config file
	
	Scenario: Generate Interactive Brokers configuration
		When I run `mtw configure localhost 7496`
		Then the following files should exist:
			| ../../config/interactive_brokers.rb |
		Then the file "../../config/interactive_brokers.rb" should contain "localhost"
		Then the file "../../config/interactive_brokers.rb" should contain "7496"

	Scenario: Display Interactive Brokers configuration
		When I run `mtw config`
		Then the output should contain "Host:"
		Then the output should contain "Port:"