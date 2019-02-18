# frozen_string_literal: true

module IAmICan
  module Subject
    module PermissionQuerying
      # TODO: without: :group
      def can? action, o = nil, obj: o, without_group: false
        temporarily_can?(action, obj) ||
            stored_can?(action, obj) ||
            group_can?(action, obj, without_group)
      end

      def cannot? action, o = nil, obj: o
        !can? action, obj
      end

      def can! action, o = nil, obj: o
        raise InsufficientPermission if cannot? action, obj
        true
      end

      def can_one_of? actions, o = nil, obj: o
        can? actions, obj
      end

      def can_one_of! actions, o = nil, obj: o
        raise InsufficientPermission unless can_one_of? actions, obj
        true
      end

      def can_each? actions, o = nil, obj: o
        # TODO: using `matched_all?`
        actions.each { |action| return false if cannot? action, obj } && true
      end

      alias can_every? can_each?

      def can_each! actions, o = nil, obj: o
        actions.each { |action| can! action, obj } && true
      end

      alias can_every! can_each!

      def temporarily_can? action, obj
        return false if try(:temporary_roles).blank?
        valid_temporary_roles.can?(action, obj)
      end

      def stored_can? action, obj
        _roles.can?(action, obj)
      end

      def group_can? action, obj, without_group = false
        return false if without_group || i_am_i_can.without_group
        _roles._role_groups._permissions.matched?(action, obj)
      end
    end
  end
end
