module IAmICan
  module Role
    def roles;       @_roles ||= { } end
    def role_groups; @_role_groups ||= { } end

    def has_role *names, save: false
      names.each { |name| roles[name] ||= { } }
    end

    alias has_roles     has_role
    alias declare_role  has_role
    alias declare_roles has_role

    def store_role *names, **options
      has_roles *names, **options
      # real_name = :"#{name.underscore}_#{name}"
      # TODO
    end

    alias store_roles store_role

    # TODO: RoleGroup model
    def group_roles *members, by_name:, save: false
      raise Error, 'This role has not been defined.' unless (members - roles.keys).empty?

      members.each { |member| ((roles[member][:group] ||= [ ]) << by_name).uniq! }
      ((role_groups[by_name] ||= [ ]).concat(members)).uniq!
    end

    alias groups_roles group_roles

    def has_and_group_roles *members, by_name:, save: false
      has_roles *members, save: save
      group_roles *members, by_name: by_name, save: save
    end

    alias has_and_groups_roles has_and_group_roles

    def members_of_role_group name
      role_groups.fetch(name)
    end

  #   # TODO: base_role => parent_role
  #   # TODO: support multi-level tree
  #   def org_roles *children, by_parent:, **options
  #     has_role  by_parent, options.merge!(children: children)
  #     has_roles children, options.merge!(parent: by_parent)
  #   end
  end
end
