# frozen_string_literal: true

require 'i_am_i_can/configs/config'

module IAmICan
  module Configs
    cattr_accessor :configs, default: { }

    def self.set_for(subject:, role:, permission:, role_group: nil, &block)
      config = Config.new(subject, role, permission, role_group)
      config.instance_eval(&block)
      configs.merge!(
          subject => config.dup,
          role => config.dup,
          permission => config.dup,
      )
      configs.merge!(role_group => config.dup) if role_group
      config
    end

    def self.get(class_name)
      configs[class_name]
    end
  end
end
