# @attr [Object] record the record from which the report's attributes will be fetched
# @attr [Object] report the report with the configuration of how to reach the report's attributes
# @attr [String, Symbol] name the fetched name value
# @attr [Object] user the fetched user object
# @attr [Object] group the fetched group object
# @attr [Time] created_at the fetched timestamp value
# @attr [Hash] metrics the prepared metrics hash
module Innsights
  module Fetchers
    class Record
      include Innsights::Helpers::Config

      attr_accessor :record, :report, :name, :user, :group, :metrics, :created_at, :condition

      def initialize(record, report)
        @record = record
        @report = report
        @name = attr_call(report.name)
        @user = attr_call(report.report_user)
        @group = attr_call(report.report_group)
        @created_at = attr_call(report.created_at_method)
        @metrics = fetch_metrics(report.metrics)
      end

      # Prepared hash to create a new Report
      # contains: name, user, :group, created_at and metrics for the report
      # 
      # @return [Hash] with the attributes needed by the Report
      def options
        {user: user, group: group, created_at: created_at, measure: metrics}
      end

      # Specifies if the report should be sent to the service
      # evaluates the reports condition method, block or primitive. True by default
      #
      # @return [Boolean] true when it should be run, false when it shouldn't
      def run?
        return true if report.condition.nil?
        return attr_call(report.condition)
      end

      private

      def fetch_metrics(raw_metrics)
        result = {}
        raw_metrics.each do |key, value|
          metric_value = attr_call(value)
          result[key] = metric_value unless metric_value.nil?
        end
        result
      end

      def attr_call(call)
        dsl_call(record, call)
      end
    end
  end
end