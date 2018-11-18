require 'i_am_i_can/permission/p_array'
require 'i_am_i_can/permission/definition'
require 'i_am_i_can/permission/assignment'

module IAmICan
  module Permission
    extend ActiveSupport::Concern

    class_methods do
      def matched?(pms_name = nil, pred: nil, obj: nil, **options)
        PArray.new(options[:in]).matched?(pms_name || naming(pred, obj))
      end

      def which(pred:, obj: nil, **conditions)
        find_by!(pred: pred, **deconstruct_obj(obj), **conditions)
      end

      def naming(pred, obj)
        obj_type, obj_id = deconstruct_obj(obj).values
        otp = "_#{obj_type}" if obj_type.present?
        oid = "_#{obj_id}" if obj_id.present?
        [pred, otp, oid].join.to_sym
      end

      def deconstruct_obj(obj)
        return { } unless obj

        if obj.is_a?(String) || obj.is_a?(Symbol)
          { obj_type: obj }
        elsif obj.respond_to?(:attributes)
          { obj_type: obj.class.name, obj_id: obj.id }
        else
          { obj_type: obj.to_s, obj_id: nil }
        end
      end

      def exists?(pred, obj)
        super(pred: pred, **deconstruct_obj(obj))
      end
    end

    included do
      # like: manage_User_1
      def name
        [pred, obj_type, obj_id].compact.join('_').to_sym
      end

      # def assign_to role: nil, group: nil
      #   obj = if role
      #           role.is_a?(Symbol) ? i_am_i_can.role_model.find(name: role) : role
      #         else
      #           group.is_a?(Symbol) ? i_am_i_can.role_group_model.find(name: role) : group
      #         end
      #   obj.have_permission self.pred, obj: self.obj
      # end
      #
      # alias is_assigned_to assign_to

      # :user, User, user
      def obj
        return obj_type.constantize.find(obj_id) if obj_id.present?
        obj_type[/[A-Z]/] ? obj_type.constantize : obj_type.to_sym
      end
    end
  end
end
