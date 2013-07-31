Feature: Interactive Brokers
	In order to determine the front month Crude future contract
	As a CLI
	I want to use the CME Group product calendar and verify with Interactive Brokers

	Scenario: CL
		When I run `mtw CL`
		Then the output should contain "Front month:"

	Scenario: QM
		When I run `mtw QM`
		Then the output should contain "Front month:"