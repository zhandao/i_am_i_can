module IAmICan
  class Config
    attr_accessor :subject_model, :role_model, :role_group_model, :permission_model,
                  :auto_define_before, :strict_mode, :without_group, :default_save

    def initialize(**options)
      self.auto_define_before = false
      self.strict_mode = false
      self.without_group = false
      self.default_save = true
      options.each { |(key, val)| self.send("#{key}=", val) }
    end
  end
end
