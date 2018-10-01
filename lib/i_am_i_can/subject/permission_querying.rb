module IAmICan
  module Subject
    module PermissionQuerying
      def can? pred, obj0 = nil, obj: nil, without_group: false
        obj = obj0 || obj
        return true if temporarily_can?(pred, obj)
        return true if stored_can?(pred, obj)
        group_can?(pred, obj, without_group)
      end

      def cannot? pred, obj0 = nil, obj: nil
        !can? pred, obj0, obj: obj
      end

      def can! pred, obj0 = nil, obj: nil
        raise InsufficientPermission if cannot? pred, obj0, obj: obj
        true
      end

      def can_each? preds, obj0 = nil, obj: nil
        preds.each { |pred| return false if cannot? pred, obj0, obj: obj } && true
      end

      alias can_every? can_each?

      def can_each! preds, obj0 = nil, obj: nil
        raise InsufficientPermission unless can_each? preds, obj0, obj: obj
        true
      end

      alias can_every! can_each!

      def can_one_of? preds, obj0 = nil, obj: nil
        preds.each { |pred| return true if can? pred, obj0, obj: obj } && false
      end

      def can_one_of! preds, obj0 = nil, obj: nil
        raise InsufficientPermission unless can_one_of? preds, obj0, obj: obj
        true
      end

      def temporarily_can? pred, obj
        ii_config.permission_model.matched?(pred: pred, obj: obj, in: permissions_of_local_roles)
      end

      alias locally_can? temporarily_can?

      def stored_can? pred, obj
        ii_config.permission_model.matched?(pred: pred, obj: obj, in: permissions_of_stored_roles)
      end

      def group_can? pred, obj, without_group = false
        return false if without_group || ii_config.without_group
        ii_config.permission_model.matched?(pred: pred, obj: obj, in: permissions_of_role_groups)
      end

      def permissions_of_stored_roles
        stored_roles.stored_permissions.map(&:name)
      end

      def permissions_of_role_groups
        stored_roles.related_role_groups.stored_permissions.map(&:name)
      end

      def permissions_of_local_roles
        local_roles.map { |(name, info)| info[:permissions] }.flatten.uniq
      end
    end
  end
end
