module Innsights
  class Config::User
    def self.id(value)
      Innsights.user_id = value.to_sym
    end
    def self.display(value)
      Innsights.user_display = value.to_sym
    end
    def self.group(value)
      Innsights.group_call = value.to_sym
    end
  end
end