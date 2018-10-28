module IAmICan
  module Role
    module Methods
      module Cls
        # def _to_store_role name, **options
        #   return false if i_am_i_can.role_model.exists?(name: name) || i_am_i_can.role_group_model&.exists?(name: name)
        #   i_am_i_can.role_model.create!(name: name, **options)
        # end
        #
        # def _role_definition_result(names, failed_items)
        #   prefix = 'Role Definition Done'
        #   fail_msg = prefix + ", but name #{failed_items} have been used by other role or group" if failed_items.present?
        #   raise Error, fail_msg if i_am_i_can.strict_mode && fail_msg
        #   puts fail_msg || prefix unless ENV['ITEST']
        #   prefix.present?
        # end

        def defined_stored_role_names
          i_am_i_can.role_model.pluck(:name).map(&:to_sym)
        end

        def defined_stored_roles
          i_am_i_can.role_model.all.map { |role| [ role.name.to_sym, role.remarks ] }.to_h
        end

        def defined_roles
          defined_temporary_roles.deep_merge(defined_stored_roles)
        end

        def defined_role_group_names
          i_am_i_can.role_group_model.pluck(:name).map(&:to_sym)
        end

        def defined_role_groups
          i_am_i_can.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym).sort ] }.to_h
        end
      end
    end
  end
end
