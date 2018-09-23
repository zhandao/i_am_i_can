module IAmICan
  class Config
    attr_accessor :model, :role_model, :role_group_model, :permission_model, :auto_define_before, :strict_mode

    def initialize(**options)
      options.each { |(key, val)| self.send("#{key}=", val) }
    end
  end
end
