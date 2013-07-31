require 'thor/group'

module MyTradeWizard
  module Generators
    class InteractiveBrokers < Thor::Group

      include Thor::Actions
      
      argument :host, :type => :string
      argument :port, :type => :numeric
      
      def create_config
        empty_directory("config")
      end
      
      def copy_config
        template("interactive_brokers.rb", "config/interactive_brokers.rb", {force: true})
      end
      
      def self.source_root
        File.dirname(__FILE__) + "/config"
      end

    end
  end
end