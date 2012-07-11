class RunReport
  @queue = :report_queue  
  def self.perform(action)
    Innsights.client.report(action)
  end
end
