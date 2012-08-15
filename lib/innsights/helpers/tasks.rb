require 'progressbar'

module Innsights
  module Helpers::Tasks
    
    def push(report)
      if report.valid_for_push?
        begin
          actions = []
          puts "==Preparing #{report.klass} records=="
          progress_actions report.klass do |record|
            actions << Innsights::Action.new(report, record).as_hash
          end 
          upload_content(actions.to_json) if actions.any?
          true
        rescue Exception => e
          Innsights::ErrorMessage.log(e)
        end
      end
    end
    
    def progress_actions(klass)
      begin
        bar = ProgressBar.new(klass.to_s.pluralize, 100)
        percent = klass.count / 100
        count   = 0
        klass.find_each do |record|
          yield(record)
          count += 1
          bar.inc if !percent.zero? && (count % percent).zero?
        end
      rescue NoMethodError => e
        Innsights::ErrorMessage.log(e)
      ensure 
        bar.finish
      end
    end
    
    def upload_content(content)
      if Innsights.client
        Tempfile.open('innsights') do |file|
          file.write content
          file.rewind
          Innsights.client.push(file)
        end
      else
        Innsights::ErrorMessage.log("No client for Innsights.")
      end
    end
    
  end
end
