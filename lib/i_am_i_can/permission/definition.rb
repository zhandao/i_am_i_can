require 'i_am_i_can/permission/methods'
require 'i_am_i_can/permission/p_array'

module IAmICan
  module Permission
    module Definition
      include Methods::Cls

      def have_permission *preds, obj: nil, save: i_am_i_can.saved_by_default
        failed_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          if save
            failed_items << pms_name unless _to_store_permission(pred, obj)
          else
            failed_items << pms_name if pms_name.in?(defined_local_permissions.keys)
            defined_local_permissions[pms_name] ||= { }
          end
        end

        _pms_definition_result(preds, obj, failed_items)
      end

      alias have_permissions have_permission
      alias has_permission   have_permission
      alias has_permissions  have_permission

      def declare_permission *preds, **options
        have_permission *preds, **options, save: false
      end

      alias declare_permissions declare_permission

      def self.extended(kls)
        kls.delegate :defined_permissions, :pms_naming, :deconstruct_obj, :pms_of_defined_local_role, to: kls
      end
    end
  end
end
