require 'i_am_i_can/permission/methods'
require 'i_am_i_can/permission/p_array'

module IAmICan
  module Permission
    module Definition
      include Methods::Cls

      def have_permission *preds, obj: nil
        failed_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          failed_items << pms_name unless _to_store_permission(pred, obj)
        end

        _pms_definition_result(preds, obj, failed_items)
      end

      alias have_permissions have_permission
      alias has_permission   have_permission
      alias has_permissions  have_permission

      def self.extended(kls)
        kls.delegate :pms_naming, :deconstruct_obj, to: kls
      end
    end
  end
end
