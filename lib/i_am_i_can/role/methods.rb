module IAmICan
  module Role
    module Methods
      module Cls
        def defined_roles
          defined_temporary_roles.map { |name, val| { name => val } } + i_am_i_can.role_model.all
        end

        def defined_role_names
          i_am_i_can.role_model.all.names + defined_temporary_roles.keys
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
