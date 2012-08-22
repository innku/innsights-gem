module Innsights
  class Config::GenericReport < Config::Report
    def initialize(action_name, options=nil)
      super()
      @action_name = action_name
      set_options(options)
    end

    def commit
      Innsights.reports << self
    end

    private
    
    def set_options(options)
      if options.is_a?(Hash)
        option_equivalences.each do |self_k, api_k|
          self.instance_variable_set("@#{self_k}", options[api_k]) if options.has_key?(api_k)
        end
      else
        @report_user = options
      end
    end

    def option_equivalences
      {created_at: :created_at, 
       report_user: :user, 
       report_group: :group,
       metrics: :measure }
    end
  end
end
