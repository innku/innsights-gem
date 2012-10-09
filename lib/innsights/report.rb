# @attr [String] name the name of the reported action
# @attr [Object, nil] user the user record actor in the action
# @attr [Object, nil] group the group that the actor user of the action belongs to
# @attr [Time] created_at time at which the action ocurred
# @attr [Hash] hash of metrics the action is affecting
module Innsights
  class Report

    attr_accessor :name, :user, :created_at, :metrics

    # @todo created_at default should be formatted to unix timestamp as soon as Innsights accepts it
    def initialize(name, options=nil)
      options ||= {}
      @name = name
      @user_object = options[:user]
      @group_object = fetch_group(options[:group])
      @created_at = options[:created_at] || Time.now
      @metrics = options[:measure] || {}
    end

    # Hashed value prepared for posting to service via the client class
    # 
    # @return [Hash] contains values for name, created_at, user, group and metrics
    # @example for a full report
    #   report.to_hash # => {name: 'Publish Post', created_at: }
    def to_hash
      value = {name: name, created_at: created_at}
      value.merge!({user: user.to_hash})   if user.present?
      value.merge!({group: group.to_hash}) if group.present?
      value.merge!({metrics: metrics})     if metrics.present?
      {:report => value}
    end

    # Posts the prepared report information to Innsights
    # Will either queue or not depending on user configuration
    def run
      if Innsights.enabled?
        case Innsights.queue_system
          when :resque; Resque.enqueue(RunReport, self.to_hash)
          when :delayed_job; Innsights.client.delay.report(self.to_hash)
          else; Innsights.client.report(self.to_hash)
        end
      end
    end

    # An encapsulation object of the group that the user that performs the action belongs to.
    # If the user configuration contains a group, it will call this method
    # to get the user object, if the report explicitly sets the group attribute
    # it will supercede the user configuration
    #
    # @return [Object, nil] User group object, nil if no explicit or user configuration
    def group
      @group ||= Innsights::Fetchers::Group.new(@group_object) if @group_object
    end

    # An encapsulation object of the user that performs the action
    # 
    # @return [Object, nil] User object, nil if no explicit user given
    def user
      @user ||= Innsights::Fetchers::User.new(@user_object) if @user_object
    end

    private

    def fetch_group(group_object)
      return group_object if group_object.present?
      return user.group if user.present?
      nil
    end

  end
end
