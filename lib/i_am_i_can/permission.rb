module IAmICan::Permission
  def current_permissions
    @_current_permissions ||= { }
  end

  # TODO: 高消耗操作?
  # TODO:父子形式输出
  def all_permissions
    permissions_setting
    current_permissions.keys.map do |key|
      # TODO: 带有 block 的判断是无法在这里进行的，所以不返回
      next if key.match?(/_block/)
      can?(key) ? key : nil rescue nil
    end.compact
  end

  def role *roles, can:, source: nil, when: true, &block
    roles = roles.first if roles.first.is_a?(Array)
    can can, source, role: roles, when: binding.local_variable_get(:when), &block
  end

  def role_group group, options, &block
    roles_groups[group].each do |role|
      self.role role, options, &block
    end
  end

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
    permissions_setting # TODO: 优化，考虑询问非预设置的 action 时再查相应数据

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

  # TODO: 支持 group 和 family 的持久化
  # TODO: cache key configure
  # TODO: 父子权限：如果父权限无效，则子孙无效，逻辑同 role family
  def load_permissions_from_database
    roles_setting # TODO: 优化（这句还是必要的，如果不是所有都走数据库）
    # TODO: 一个发现的问题是，console 和 rails server 的 cache 似乎是不共享的？或者说是其他问题？
    Rails.cache.fetch("#{self.class.name.underscore}_#{self.id}_permissions") do
      assoc_roles = roles.includes(:role_permissions, :permissions).to_a
      role_permissions = assoc_roles.map(&:role_permissions).flatten.uniq
      base_role_permissions = assoc_roles.map(&:base_role).compact.map(&:role_permissions).flatten.uniq # TODO: 优化
      entity_permissions = EntityPermission.where(permission_id: self.permissions.pluck(:id))
      relations = [ *role_permissions, *base_role_permissions, *entity_permissions ]

      relations.map do |relation|
        pmi = relation.permission
        [ :can, pmi.name.to_sym, pmi.source, { when: true } ]
      end
    end.each { |args| send(*args) }
  end

  def permissions_setting
    @_current_permissions = { }
    load_permissions_from_database
  end

  class InsufficientPermission < StandardError; end
end
