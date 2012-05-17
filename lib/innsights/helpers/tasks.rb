require 'progressbar'

module Innsights
  module Helpers::Tasks
    
    def push(report)
      report_actions = []
      puts "==Preparing #{report.klass} records=="
      progress_actions report.klass do |record|
        report_actions << Innsights::Action.new(report, record).as_hash
        if report_actions.size >= 3500
          upload_content(report_actions.to_json)
          report_actions = []
        end
      end
      upload_content(report_actions.to_json) if report_actions.any?
    end
    
    def progress_actions(klass)
      bar = ProgressBar.new(klass.to_s.pluralize, 100)
      percent = klass.count / 100
      count   = 0
      klass.find_each do |record|
        yield(record)
        count += 1
        bar.inc if !percent.zero? && (count % percent).zero?
      end
      bar.finish
    end
    
    def upload_content(content)
      Tempfile.open('innsights') do |file|
        file.write content
        file.rewind
        Innsights.client.push(file)
      end
    end
    
  end
end