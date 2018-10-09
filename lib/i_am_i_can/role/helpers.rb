module IAmICan
  module Role
    module Helpers
      module Cls
        def _to_store_role name, **options
          return false if ii_config.role_model.exists?(name: name) || ii_config.role_group_model&.exists?(name: name)
          ii_config.role_model.create!(name: name, **options)
        end

        def _role_definition_result(names, failed_items)
          prefix = 'Role Definition Done'
          fail_msg = prefix + ", but name #{failed_items} have been used by other role or group" if failed_items.present?
          raise Error, fail_msg if ii_config.strict_mode && fail_msg
          fail_msg ? fail_msg : prefix
        end
      end

      module Ins
        def _role_assignment_result(names, failed_items)
          prefix = 'Role Assignment Done'
          fail_msg = prefix + ", but #{failed_items} have not been defined" if failed_items.present?
          raise Error, fail_msg if ii_config.strict_mode && fail_msg
          fail_msg ? fail_msg : prefix
        end
      end
    end
  end
end
