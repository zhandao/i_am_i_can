require 'i_am_i_can/configs/config'

module IAmICan
  module Configs
    cattr_accessor :configs do
      { }
    end

    def self.set_for(subject:, role:, permission:, role_group: nil, &block)
      config = Config.new(subject, role, permission, role_group)
      config.instance_eval(&block)
      configs.merge!(
          subject => config,
          role => config,
          permission => config,
      )
      configs.merge!(role_group => config) if role_group
      config
    end

    def self.get(class_name)
      configs[class_name]
    end
  end
end
