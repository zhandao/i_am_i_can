require 'i_am_i_can/permission/pms_array'

module IAmICan
  module Permission
    module Methods
      module Cls
        def _pms_definition_result(preds, obj, failed_items)
          prefix = 'Permission Definition Done'
          fail_msg = prefix + ", but #{failed_items} have been defined" if failed_items.present?
          raise Error, fail_msg if i_am_i_can.strict_mode && fail_msg
          puts fail_msg || prefix unless ENV['ITEST']
          prefix.present?
        end

        def _to_store_permission(pred, obj, **options)
          return false if i_am_i_can.permission_model.exists?(pred, obj)
          i_am_i_can.permission_model.create!(pred: pred, **deconstruct_obj(obj), **options)
        end

        def pms_naming(pred, obj)
          i_am_i_can.permission_model.naming(pred, obj)
        end

        def deconstruct_obj(obj)
          i_am_i_can.permission_model.deconstruct_obj(obj)
        end

        def defined_tmp_permissions
          @defined_tmp_permissions ||= { }
        end

        def defined_stored_pms_names
          i_am_i_can.permission_model.all.map(&:name)
        end

        def defined_stored_permissions
          i_am_i_can.permission_model.all
        end

        def defined_permission_names
          defined_tmp_permissions.deep_merge(defined_stored_permissions)
        end

        def pms_of_defined_local_role(role_name)
          (i_am_i_can.subject_model.defined_temporary_roles[role_name.to_sym] ||= { })[:permissions] ||= { id: [], index: [] }
        end
      end

      module Ins
        def _pms_assignment_result(preds, obj, not_defined_items, covered_items = nil, strict_mode = false)
          prefix = 'Permission Assignment Done'
          msg1 = "#{not_defined_items} have not been defined or have been repeatedly assigned" if not_defined_items.present?
          msg2 = "#{covered_items} have been covered" if covered_items.present?
          fail_msg = prefix + ', but ' + [msg1, msg2].compact.join(', ') if msg1 || msg2
          raise Error, fail_msg if (strict_mode || i_am_i_can.strict_mode) && fail_msg
          puts fail_msg || prefix unless ENV['ITEST']
          prefix.present?
        end

        def pms_matched?(pms_name, plist)
          i_am_i_can.permission_model.matched?(pms_name, in: plist[:in])
        end

        def local_permissions
          @local_permissions ||= [ ]
        end

        alias local_permission_names local_permissions

        # TODO: show by hash
        def permissions
          local_permission_names + stored_permission_names
        end
      end
    end
  end
end
