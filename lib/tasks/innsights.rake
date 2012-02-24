include Innsights::Helpers::Tasks
include ActionView::Helpers::NumberHelper if defined?(Rails)

namespace :innsights do
  desc 'Pushes historic data to Innsights account'
  task :push => :environment do
    Innsights.reports.each do |report|
      Tempfile.open('innsights') do |file|
        content = json_actions(report)
        file.write content
        file.rewind
        puts "Uploading #{number_to_human_size file.size}..." 
        Innsights.client.push(file)
        puts "Finished pushing #{report.klass.to_s.pluralize}"
      end
    end
    puts "===Finished Pushing Records==="
  end
end