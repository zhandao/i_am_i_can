module IAmICan
  module Permission
    def deconstruct_obj(obj)
      return { } unless obj

      if obj.is_a?(String) || obj.is_a?(Symbol)
        { obj_type: obj }
      elsif obj.respond_to?(:attributes)
        { obj_type: obj.class.name, obj_id: obj.id }
      else
        { obj_type: obj.to_s }
      end
    end

    def exists?(pred, obj)
      super(pred: pred, **deconstruct_obj(obj))
    end

    def self.extended(kls)
      kls.include InstanceMethods
    end
  end

  # === End of ClassMethods ===

  module Permission::InstanceMethods
    # like: manage_User_1
    def name
      otp = "_#{obj_type}" if obj_type.present?
      oid = "_#{obj_id}" if obj_id.present?
      [pred, otp, oid].join.to_sym
    end

    def assign_to role: nil, group: nil
      obj = if role
              role.is_a?(Symbol) ? ii_config.role_model.find(name: role) : role
            else
              group.is_a?(Symbol) ? ii_config.role_group_model.find(name: role) : group
            end
      obj.have_permission self.pred, obj: self.obj
    end

    # :user, User, user
    def obj
      return obj_type.constantize.find(obj_id) if obj_id.present?
      obj_type[/[A-Z]/] ? obj_type.constantize : obj_type.to_sym
    end
  end
end
