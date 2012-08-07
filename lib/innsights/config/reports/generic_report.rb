module Innsights
  class Config::GenericReport < Config::Report
    def initialize(action_name, app_user)
      super()
      @action_name = action_name
      @report_user = app_user
    end

    def commit
      Innsights.reports << self
    end
  end
end
