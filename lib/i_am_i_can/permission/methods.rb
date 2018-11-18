module IAmICan
  module Permission
    module Methods
      module Cls
        def pms_naming(pred, obj)
          i_am_i_can.permission_model.naming(pred, obj)
        end

        def deconstruct_obj(obj)
          i_am_i_can.permission_model.deconstruct_obj(obj)
        end

        def defined_stored_pms_names
          i_am_i_can.permission_model.all.map(&:name)
        end
      end

      module Ins
        def pms_matched?(pms_name, plist)
          i_am_i_can.permission_model.matched?(pms_name, in: plist[:in])
        end
      end
    end
  end
end
