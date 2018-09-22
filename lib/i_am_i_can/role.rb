module IAmICan
  module Role
    def have_role *names, desc: nil, save: true, which_can: []
      failed_items = [ ]

      names.each do |name|
        description = desc || name.to_s.humanize
        if save
          failed_items << name unless _to_store_role(name, desc: description)
        else
          failed_items << name if local_roles.key?(name)
          local_roles[name] ||= { desc: description }
        end
      end

      raise Error, "Done, but name #{failed_items} have been used by other role or group" if failed_items.present?
      names
    end

    alias have_roles have_role
    alias has_role   have_role
    alias has_roles  have_role

    def _to_store_role name, **options
      return false if ii_config.role_model.exists?(name: name) || ii_config.role_group_model.exists?(name: name)
      ii_config.role_model.create!(name: name, **options)
    end

    def declare_role *names, **options
      has_role *names, save: false, **options
    end

    alias declare_roles has_role

    def group_roles *members, by_name:
      raise Error, 'Some of members have not been defined' unless (members - stored_role_names).empty?
      raise Error, "Given name #{by_name} has been used by a role" if ii_config.role_model.exists?(name: by_name)
      ii_config.role_group_model.find_or_create_by!(name: by_name).members_add(members)
    end

    alias group_role   group_roles
    alias groups_role  group_roles
    alias groups_roles group_roles

    def have_and_group_roles *members, by_name:
      has_roles *members
      group_roles *members, by_name: by_name
    end

    alias has_and_groups_roles have_and_group_roles
  end

  # === End of MainMethods ===

  module Role::SecondaryMethods
    def local_roles
      @local_roles ||= { }
    end

    def stored_role_names
      ii_config.role_model.pluck(:name).map(&:to_sym)
    end

    def stored_roles
      ii_config.role_model.all.map { |role| [ role.name.to_sym, role.desc ] }.to_h
    end

    def roles
      local_roles.merge(stored_roles)
    end

    def role_group_names
      ii_config.role_group_model.pluck(:name).map(&:to_sym)

    end
    def role_groups
      ii_config.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym) ] }.to_h
    end

    def members_of_role_group name
      ii_config.role_group_model.find_by!(name: name).member_names
    end

    #   # TODO: base_role => parent_role
    #   # TODO: support multi-level tree
    #   def org_roles *children, by_parent:, **options
    #     has_role  by_parent, options.merge!(children: children)
    #     has_roles children, options.merge!(parent: by_parent)
    #   end

    Role.include self
  end
end
