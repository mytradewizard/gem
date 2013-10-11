require 'thor/group'

module MyTradeWizard
  module Generators
    class MyTradeWizard < Thor::Group

      include Thor::Actions

      argument :environment, :type => :string
      argument :host, :type => :string
      argument :port, :type => :numeric
      argument :account, :type => :string
      argument :email_to, :type => :string
      argument :gmail_username, :type => :string
      argument :gmail_password, :type => :string
      
      def create_config
        empty_directory("config")
      end
      
      def copy_config
        template("mytradewizard.rb", "config/mytradewizard.rb", {force: true})
      end
      
      def self.source_root
        File.dirname(__FILE__) + "/config"
      end

    end
  end
end