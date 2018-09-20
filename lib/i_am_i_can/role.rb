module IAmICan
  module Role
    def has_role *names, desc: nil, save: false
      names.map do |name|
        description = desc || name.to_s.humanize
        to_store_role(name: name, desc: description) if save
        next "Role #{name} has been defined" if local_roles.key?(name)
        local_roles[name] ||= { desc: description } && name
      end
    end

    alias has_roles     has_role
    alias declare_role  has_role
    alias declare_roles has_role

    def group_roles *members, by_name:
      raise Error, 'Some of members have not been defined' unless (members - stored_role_names).empty?
      to_store_role_group(by_name, members)
    end

    alias groups_roles group_roles
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

    def to_store_role(name:, **options)
      return "Role #{name} has been stored" if ii_config.role_model.exists?(name: name)
      ii_config.role_model.create!(name: name, **options)
    end

    def to_store_role_group name, members
      role_group = ii_config.role_group_model.find_or_create_by!(name: name)
      raise Error, "Could not find role #{name}" unless role_group.members_add(members)
    end

    def store_role *names, **options
      has_role *names, save: true, **options
    end

    def has_and_group_roles *members, by_name:
      has_roles *members, save: true
      group_roles *members, by_name: by_name
    end

    alias has_and_groups_roles has_and_group_roles

    def role_group_names
      ii_config.role_group_model.pluck(:name).map(&:to_sym)

    end
    def role_groups
      ii_config.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym) ] }.to_h
    end

    def members_of_role_group name
      ii_config.role_group_model.find_by!(name: name).member_names.map(&:to_sym)
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

__END__

=== ModelRole ===

    t.string :name, null: false
    t.string :desc

    add_index :user_roles, :name, unique: true, using: :btree

=== ModelRoleGroup ===

    t.string  :name,    null: false, index: true
    t.integer :members, array: true, default: [ ]

    add_index :user_role_groups, :name, unique: true, using: :btree
