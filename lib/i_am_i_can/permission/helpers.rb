module IAmICan
  module Permission
    module Helpers
      module Cls
        def _pms_definition_result(preds, obj, failed_items)
          prefix = 'Permission Definition Done'
          fail_msg = prefix + ", but #{failed_items} have been defined" if failed_items.present?
          raise Error, fail_msg if  config.strict_mode && fail_msg
          fail_msg ? fail_msg : prefix
        end

        def _to_store_permission(pred, obj, **options)
          return false if config.permission_model.exists?(pred, obj)
          config.permission_model.create!(pred: pred, **deconstruct_obj(obj), **options)
        end

        def pms_naming(pred, obj)
          obj_type, obj_id = deconstruct_obj(obj).values
          otp = "_#{obj_type}" if obj_type.present?
          oid = "_#{obj_id}" if obj_id.present?
          [pred, otp, oid].join.to_sym
        end

        def deconstruct_obj(obj)
          config.permission_model.deconstruct_obj(obj)
        end

        def pms_of_defined_local_role(role_name)
          config.subject_model.defined_local_roles[role_name.to_sym]&.[](:permissions) || []
        end
      end

      module Ins
        def _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
          prefix = 'Permission Assignment Done'
          msg1 = "#{not_defined_items} have not been defined" if not_defined_items.present?
          msg2 = "#{covered_items} have been covered" if covered_items.present?
          fail_msg = prefix + ', but ' + [msg1, msg2].compact.join(', ') if msg1 || msg2
          raise Error, fail_msg if (strict_mode || config.strict_mode) && fail_msg
          fail_msg ? fail_msg : prefix
        end
      end
    end
  end
end
