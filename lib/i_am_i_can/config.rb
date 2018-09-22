module IAmICan
  class Config
    attr_accessor :role_model, :role_group_model, :permission_model, :use_after_define

    def initialize(**options)
      options.each { |(key, val)| self.send("#{key}=", val) }
    end
  end
end
