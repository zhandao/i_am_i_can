module IAmICan
  class Config
    attr_accessor :role_model, :role_group_model

    def initialize(model:, **options)
      self.role_model = "#{model}Role".constantize
      self.role_group_model = "#{model}RoleGroup".constantize
      options.each { |(key, val)| self.send("#{key}=", val) }
    end
  end
end
