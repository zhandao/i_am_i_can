# frozen_string_literal: true

module IAmICan
  module Reflection
    extend ActiveSupport::Concern

    class_methods do
      def _reflect_of(key)
        _name = i_am_i_can&.send("#{key}_class")
        reflections.each do |name, reflection|
          return name if reflection.class_name == _name
        end; nil
      end

      %w[ subjects roles role_groups permissions ].each do |k|
        # User.__roles => 'stored_roles'
        define_method "__#{k}" do
          instance_variable_get(:"@__#{k}") or
              instance_variable_set(:"@__#{k}", _reflect_of(k.singularize))
        end

        # User.all._roles == User.all.stored_roles
        define_method "_#{k}" do
          send(send("__#{k}")) rescue (raise NoMethodError)
        end
      end
    end

    included do
      # user._roles => Association CollectionProxy, same as: `user.stored_roles`
      %w[ subjects roles role_groups permissions ].each do |k|
        delegate "__#{k}", to: self

        define_method "_#{k}" do
          send(send("__#{k}")) rescue (raise NoMethodError)
        end
      end
    end
  end
end
