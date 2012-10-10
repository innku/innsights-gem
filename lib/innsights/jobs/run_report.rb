module Innsights
  # Job currently used only for Resque queuing system
  class RunReport
    @queue = :report_queue  
    # Reports action to the API Service through Innsights::Client
    # 
    # @param [Hash] action report action attributes
    # @example
    #   Resque.enqueue(Innsights::Jobs::RunReport, action.to_hash)
    def self.perform(action)
      Innsights.client.report(action)
    end
  end
end