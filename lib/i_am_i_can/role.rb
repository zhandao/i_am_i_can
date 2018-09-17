module IAmICan
  module Role
    def roles;       @_roles ||= { }       end
    def role_groups; @_role_groups ||= { } end

    def has_role *names, desc: nil, save: false
      names.map do |name|
        description = desc || name.to_s.humanize
        to_store_role(name: name, desc: description) if save
        next "Role #{name} has been defined" if roles.key?(name)
        roles[name] ||= { desc: description } && name
      end
    end

    alias has_roles     has_role
    alias declare_role  has_role
    alias declare_roles has_role

    def group_roles *members, by_name:, save: false
      raise Error, 'Some of members have not been defined' unless (members - roles.keys).empty?
      to_store_role_group(by_name, members) if save
      ((role_groups[by_name] ||= [ ]).concat(members)).uniq!
    end

    alias groups_roles group_roles
  end

  # === End of MainMethods ===

  module Role::SecondaryMethods
    def to_store_role(name:, **options)
      return "Role #{name} has been stored" if ii_config.role_model.exists?(name: name)
      ii_config.role_model.create!(name: name, **options)
    end

    def to_store_role_group name, members
      role_group = ii_config.role_group_model.find_or_create_by!(name: name)
      role_ids = ii_config.role_model.where(name: members).ids
      (role_group.member_ids.concat(role_ids)).uniq!
      role_group.save!
    end

    def store_role *names, **options
      has_role *names, save: true, **options
    end

    def has_and_group_roles *members, by_name:, save: false
      has_roles *members, save: save
      group_roles *members, by_name: by_name, save: save
    end

    alias has_and_groups_roles has_and_group_roles

    def store_group_roles *members, by_name:
      has_roles *members, save: true
      group_roles *members, by_name: by_name, save: true
    end

    def members_of_role_group name
      role_groups.fetch(name)
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
