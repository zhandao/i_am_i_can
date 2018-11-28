module IAmICan
  module Subject
    module PermissionQuerying
      def can? pred, o = nil, obj: o, without_group: false
        temporarily_can?(pred, obj) ||
            stored_can?(pred, obj) ||
            group_can?(pred, obj, without_group)
      end

      def cannot? pred, o = nil, obj: o
        !can? pred, obj
      end

      def can! pred, o = nil, obj: o
        raise InsufficientPermission if cannot? pred, obj
        true
      end

      def can_each? preds, o = nil, obj: o
        preds.each { |pred| return false if cannot? pred, obj } && true
      end

      alias can_every? can_each?

      def can_each! preds, o = nil, obj: o
        preds.each { |pred| can! pred, obj } && true
      end

      alias can_every! can_each!

      def can_one_of? preds, o = nil, obj: o
        preds.each { |pred| return true if can? pred, obj } && false
      end

      def can_one_of! preds, o = nil, obj: o
        raise InsufficientPermission unless can_one_of? preds, obj
        true
      end

      def temporarily_can? pred, obj
        valid_temporary_roles._permissions.matched?(pred, obj)
      end

      def stored_can? pred, obj
        _roles._permissions.matched?(pred, obj)
      end

      def group_can? pred, obj, without_group = false
        return false if without_group || i_am_i_can.without_group
        _roles._role_groups._permissions.matched?(pred, obj)
      end
    end
  end
end
