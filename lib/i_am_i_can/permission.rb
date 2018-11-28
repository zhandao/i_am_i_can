require 'i_am_i_can/permission/definition'
require 'i_am_i_can/permission/assignment'

module IAmICan
  module Permission
    extend ActiveSupport::Concern

    class_methods do
      def matched(preds, obj)
        _ = deconstruct_obj(obj)
        where(pred: preds,
              obj_type: [nil, _[:obj_type]],
              obj_id: [nil, _[:obj_id]])
      end

      def matched?(preds, obj)
        matched(preds, obj).present?
      end

      def matched_all?(preds, obj)
        matched(preds, obj).count == Array(preds).count
      end

      def which(pred:, obj: nil, **conditions)
        find_by!(pred: pred, **deconstruct_obj(obj), **conditions)
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

      def names
        all.map(&:name)
      end
    end

    included do
      # like: manage_User_1
      def name
        [pred, obj_type, obj_id].compact.join('_').to_sym
      end

      # def assign_to role: nil, group: nil
      # end

      # returns :user, User, user
      def obj
        return obj_type.constantize.find(obj_id) if obj_id.present?
        obj_type[/[A-Z]/] ? obj_type.constantize : obj_type.to_sym
      end
    end
  end
end
