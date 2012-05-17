include Innsights::Helpers::Tasks
include ActionView::Helpers::NumberHelper if defined?(Rails)

namespace :innsights do
  desc 'Pushes historic data to Innsights account'
  task :push => :environment do
    Innsights.reports.each do |report|
      push report
    end
    puts "===Finished Pushing Records==="
  end
end