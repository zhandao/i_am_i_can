module IAmICan
  module Subject
    module PermissionQuerying
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        return true if temporarily_can?(pred, obj)
        permission = ii_config.permission_model.which(pred: pred)
        return true if is_one_of? *permission.related_roles.map(&:name)
        is_in_one_of? *permission.related_role_groups.map(&:name)
      end

      def cannot? pred, obj0 = nil, obj: nil
        !can? pred, obj0, obj: obj
      end

      def can!
        #
      end

      def can_each?
        #
      end

      alias can_every? can_each?

      def can_each!
        #
      end

      alias can_every! can_each!

      def temporarily_can? pred, obj
        stored_roles.each { |role| return true if role.temporarily_can? pred, obj } && false
      end

      alias locally_can? temporarily_can?
    end
  end
end
