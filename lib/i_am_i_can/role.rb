module IAmICan
  module Role
    def roles;       @_roles ||= { } end
    def role_groups; @_role_groups ||= { } end

    def has_role *names, children: nil, parent: nil
      names.each { |name| roles[name] = { children: children ? Array(children) : nil, parent: parent } }
    end

    alias declare_role has_role

    def store_role name, *args
      has_role name, *args
      # real_name = :"#{name.underscore}_#{name}"
      # TODO
    end

    # Case 1: *roles, by_name:
    # Case 2: by_name: , &block
    def group_roles *members, by_name:, &block
      if block_given?
        _roles = roles
        instance_eval(&block)
        members = roles.keys - _roles.keys
      end

      role_groups[by_name] = members
    end

    def org_role parent:, **options, &block
      _roles = roles
      instance_eval(&block)
      new_roles = roles.keys - _roles.keys
      has_role parent, options.merge!(children: new_roles)
      new_roles.each do |new_role|
        roles[new_role][:parent] = parent
      end
    end
  end
end
