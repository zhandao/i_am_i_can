module IAmICan
  module Permission
    module Methods
      module Cls
        def deconstruct_obj(obj)
          i_am_i_can.permission_model.deconstruct_obj(obj)
        end

        def defined_stored_pms_names
          i_am_i_can.permission_model.all.map(&:name)
        end
      end
    end
  end
end
