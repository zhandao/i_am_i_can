module IAmICan
  module Reflection
    extend ActiveSupport::Concern

    class_methods do
      def _reflect_of(key)
        _name = i_am_i_can.send("#{key}_class")
        reflections.each do |name, reflection|
          return name if reflection.class_name == _name
        end; nil
      end

      %w[ subjects roles role_groups permissions ].each do |k|
        # User.__roles => 'stored_roles'
        define_method "__#{k}" do
          v = instance_variable_get("@__#{k}")
          return v if v.present?
          instance_variable_set("@__#{k}", _reflect_of(k.singularize))
        end

        # User.all._roles == User.all.stored_roles
        define_method "_#{k}" do
          send(send("__#{k}")) if send("__#{k}")
        end
      end
    end

    included do
      # user._roles => Association CollectionProxy, same as: `user.stored_roles`
      %w[ subjects roles role_groups permissions ].each do |k|
        define_method "_#{k}" do
          send(self.class.send("__#{k}")) if self.class.send("__#{k}")
        end
      end
    end
  end
end
