module IAmICan
  module Reflection
    extend ActiveSupport::Concern

    class_methods do
      %w[ subjects roles role_groups permissions ].each do |k|
        define_method "_#{k}" do
          v = instance_variable_get("@_#{k}")
          return v if v.present?
          instance_variable_set("@_#{k}", _reflect_of_ii(k.singularize))
        end
      end
    end

    included do
      %w[ subjects roles role_groups permissions ].each do |k|
        define_method "_#{k}" do
          send(self.class.send("_#{k}")) if self.class.send("_#{k}")
        end
      end
    end
  end
end
