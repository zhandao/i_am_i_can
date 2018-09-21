module IAmICan
  module Can
    def can actions, source = nil, when: true, role: nil, &block
      [role].flatten.each do |given_role|
        Array(actions).each do |action|
          key = source ? "#{action}_#{source.class}_#{source.id}" : action
          # TODO: 怎么延迟做 when
          current_permissions[key] ||= is?(given_role) && binding.local_variable_get(:when)
          # TODO: block 不要放到 c_p
          (current_permissions["#{key}_block"] ||= [ ]) << block if block_given?
        end
      end
    end

    def current_permissions
      @_current_permissions ||= { }
    end

    def all_permissions
      current_permissions.keys.map do |key|
        next if key.match?(/_block/)
        can?(key) ? key : nil rescue nil
      end.compact
    end

    def role *roles, can:, source: nil, when: true, &block
      roles = roles.first if roles.first.is_a?(Array)
      can can, source, role: roles, when: binding.local_variable_get(:when), &block
    end

    def role_group group, options, &block
      role_groups[group].each do |role|
        self.role role, options, &block
      end
    end

    def add_permission *actions
      self.permissions << Permission.where(name: actions)
    end

    def if_case
      { when: true }
    end

    # user.can? :use, Func.find(1)
    # user.can? :manage_nodes, on: node
    def can? action, source = nil, on: nil
      return true if action.nil?

      key = source ? "#{action}_#{source.class}_#{source.id}".to_sym : action.to_sym
      current_permissions[key] && permission_blocks_result(on, key) || false
    end
    alias has_permission? can?

    def permission_blocks_result(source, key)
      blocks = current_permissions["#{key}_block"]
      return true if blocks.nil? || source.nil?
      blocks.each { |block| return true if instance_exec(source, &block) }
      false
    end

    def can! action, source = nil
      raise InsufficientPermission unless can? action, source
    end
    alias has_permission! can!

    def can_all_of? *actions, source: nil
      actions.each { |action| return false unless can? action, source }
      true
    end

    def can_all_of! *actions, source: nil
      actions.each { |action| can! action, source }
    end
  end
end
