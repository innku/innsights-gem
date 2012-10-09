# @attr [Class] klass class watched to configure a report upon a certain event
module Innsights
	module Config
	  class Model < Config::Base
			attr_accessor    :klass
			dsl :upon,       :event

			def initialize(klass)
			  @klass = klass
			  @name = klass.name
			  @created_at_method = :created_at
			  @event = :after_create
			  @metrics = {}
			end

			# Records the configuration of the report within the model and sets up for call after the event
			# 
			# @return [Class] class after being set up with the event callback
			# @example
			#   example_report = Config::ModelReport.new(User)
			#   example_report.commit # => User
			def commit
			  if valid?
					callback_process = setup(klass)
					klass.send(event, callback_process)
					klass
			  else
					Innsights::ErrorMessage.log("#{klass} doesn't respond to callback event #{event}")
			  end
			end

			# Says if the given report is valid
			#
			# @return [Boolean] false when invalid, true when valid
			# @example
			#   example_report = Config::ModelReport.new(User)
			#   User.respond_to? :after_create # => false
			#   example_report.valid? # => false
			#
			#   example_report = Config::ModelReport.new(CoolUser)
			#   CoolUser.respond_to? :after_create # => true
			#   example_report.valid? # => true
			def valid?
			  klass.respond_to?(event)
			end

			# Says if the given report is valid to push
			# only works for after_create methods
			#
			# @example 
			#   example_report = Config::ModelReport.new(User)
			#   example_report.valid_for_push? true
			#
			#   example_report.event = :after_update
			#   example_report.valid_for_push? false
			def valid_for_push?
			  [:after_create].include? self.event.to_sym
			end

	  end
	end
end

