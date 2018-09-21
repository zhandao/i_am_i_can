module IAmICan
  module Permission
    def assign_to role: nil, group: nil
      obj = if role
              role.is_a?(Symbol) ? ii_config.role_model.find(name: role) : role
            else
              group.is_a?(Symbol) ? ii_config.role_group_model.find(name: role) : group
            end
      obj.has_permission self.name
    end
  end

  # === End of MainMethods ===

  module Permission::SecondaryMethods
    #

    Permission.include self
  end
end
