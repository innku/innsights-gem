require 'progressbar'

module Innsights
  module Helpers::Tasks
    
    def push(report)
      if report.valid_for_push?
        report_actions = []
        puts "==Preparing #{report.klass} records=="
        progress_actions report.klass do |record|
          report_actions << Innsights::Action.new(report, record).as_hash
        end
        upload_content(report_actions.to_json) if report_actions.any?
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
        puts Innsights::ErrorMessage.error_msg(e)
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
        puts Innsights::ErrorMessage.error_msg_for("No client for Innsights. ")
      end
    end
    
  end
end
