module IAmICan
  module Role
    module Methods
      module Cls
        def _to_store_role name, **options
          return false if i_am_i_can.role_model.exists?(name: name) || i_am_i_can.role_group_model&.exists?(name: name)
          i_am_i_can.role_model.create!(name: name, **options)
        end

        def _role_definition_result(names, failed_items)
          prefix = 'Role Definition Done'
          fail_msg = prefix + ", but name #{failed_items} have been used by other role or group" if failed_items.present?
          raise Error, fail_msg if i_am_i_can.strict_mode && fail_msg
          puts fail_msg || prefix unless ENV['ITEST']
          prefix.present?
        end

        def defined_local_roles
          @local_roles ||= { }
        end

        def defined_stored_role_names
          i_am_i_can.role_model.pluck(:name).map(&:to_sym)
        end

        def defined_stored_roles
          i_am_i_can.role_model.all.map { |role| [ role.name.to_sym, role.desc ] }.to_h
        end

        def defined_roles
          defined_local_roles.deep_merge(defined_stored_roles)
        end

        def defined_role_group_names
          i_am_i_can.role_group_model.pluck(:name).map(&:to_sym)
        end

        def defined_role_groups
          i_am_i_can.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym).sort ] }.to_h
        end
      end

      module Ins
        def _role_assignment_result(names, failed_items)
          prefix = 'Role Assignment Done'
          fail_msg = prefix + ", but #{failed_items} have not been defined or have been repeatedly assigned" if failed_items.present?
          raise Error, fail_msg if i_am_i_can.strict_mode && fail_msg
          puts fail_msg || prefix unless ENV['ITEST']
          prefix.present?
        end

        def local_role_names
          @local_role_names ||= [ ]
        end

        def local_roles
          defined_local_roles.slice(*local_role_names)
        end

        def roles
          local_role_names + stored_role_names
        end

        alias role_names roles
      end
    end
  end
end
