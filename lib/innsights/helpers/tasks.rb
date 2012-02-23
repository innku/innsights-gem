require 'progressbar'

module Innsights
  module Helpers::Tasks
    
    def json_actions(report)
      report_actions = []
      puts "==Preparing #{report.klass} records=="
      progress_actions report.klass do |record|
        report_actions << Innsights::Action.new(report, record).as_hash
      end
      report_actions.to_json
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
    
  end
end