require 'progressbar'

module Innsights
  # Helper methods to be used in Rake Taks `rake innsights:push`
  module Helpers::Tasks
    
    # Builds and uploads a JSON File with all the historic reports to innsights
    # 
    # @param [Report] report the configured report to be pushed, currently it only supports models
    # @return [True, nil] returns true if the report was successful, if not outputs an error message 
    # @example
    #   report = Innsights.reports.last
    #   push(report) # true
    def push(report)
      if report.valid_for_push?
        begin
          actions = []
          puts "==Preparing #{report.klass} records=="
          progress_actions report.klass do |record|
            prepared_record = Innsights::Fetchers::Record.new(record, report)
            prepared_report = Innsights::Report.new(prepared_record.name, prepared_record.options)
            actions << prepared_report.to_hash if prepared_record.run?
          end 
          upload_content(actions.to_json) if actions.any?
          true
        rescue Exception => e
          Innsights::ErrorMessage.log(e)
        end
      end
    end
    
    # Iterates within the report of the class to build the JSON file
    # while processing the actions it shows a progressbar.
    # 
    # @param [ActiveRecord] klass ActiveRecord class prepared for iteration with the find_each method
    # @return [nil] finishes uploading the bar
    # @example
    #   progress_actions(Post)
    #   ==Preparing Post records==
    # => Posts:         100% |oooooooooooooooooooooooooooooooooooooooooo| Time: 00:00:00
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
    
    # Builds a JSON file from a string and uploads it to the API Service: push
    # 
    # @param [String] content the string content of a json array of objects
    # @return [String, nil] response from the API Service or nil if fails to upload outputing an error
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
