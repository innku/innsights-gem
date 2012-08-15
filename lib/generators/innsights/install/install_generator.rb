module Innsights
  class InstallGenerator < Rails::Generators::Base
    argument  :app_name, :type => :string, :default => ''
    
    source_root File.expand_path('../templates', __FILE__)
    
    def ensure_new_app
      if File.exists?(File.join(Rails.root, 'config/innsights.yml')) && !Innsights.test_mode
        puts warning && exit
      end
    end
    
    def generate_config
      @config = Innsights::Client.create(processed_app_name)
      if @config.nil?
        abort
      else
        template 'innsights.yml', 'config/innsights.yml'
      end
    end
    
    def generate_initializer
      copy_file 'innsights.rb', 'config/initializers/innsights.rb'
    end
    
    private
    
    def processed_app_name
      return app_name.parameterize unless app_name.blank?
      Rails.application.class.parent_name.parameterize
    end
    
    def warning
      <<-NOTICE
        An app seems to exist already. 
        Check your credentials at http://innsights.herokuapp.com
      NOTICE
    end
    
  end
end
