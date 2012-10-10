module Innsights 
  # Ties up the gem into the Rails boot process
  # Explicitly calls the rake tasks located in lib/tasks
  class Railtie < Rails::Railtie
    rake_tasks do 
      Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
    end
  end
end