module IAmICan::Role
  # TODO: class eval attr_
  def current_roles
    @_current_roles ||= { }
  end

  def roles_groups
    @_groups ||= { }
  end

  def roles_relations
    @_roles_relations ||= { }
  end

  # TODO: 高消耗操作?
  # TODO: 父子形式输出
  def all_roles
    roles_setting
    current_roles.keys.map { |key| is?(key) ? key : nil }.compact
  end

  # Case 1: *roles, options_hash(name)
  # Case 2: group_name, options_hash(members)
  # Case 3: group_name, &block
  def group_roles *args, arg, &block
    if block_given?
      old_roles_keys = current_roles.keys
      instance_eval(&block)
      roles_groups[arg] = current_roles.keys - old_roles_keys
    elsif arg[:members].present?
      roles_groups[args.first] = arg[:members]
    else
      roles_groups[arg[:name]] = Array(args)
    end
  end

  def in_the_group?(group)
    roles_groups.fetch(group).each do |role|
      return true if is? role
    end
    false
  end

  # TODO: source
  def is role, of: nil, when: nil, children: nil, parent: nil, &block
    role = of ? "#{role}_#{of}".to_sym : role

    (roles_relations[role] ||= { }).tap do |it|
      it[:children] ||= Array(children)
      it[:parent]   ||= parent
    end.delete_if { |_, v| v.blank? }
    current_roles[role] ||= binding.local_variable_get(:when) || block # TODO
  end
  alias add_role is

  def is? role, of: nil
    return true if role.nil?
    roles_setting # TODO: 优化

    key = of ? "#{role}_#{of.class.to_s.underscore}".to_sym : role.to_sym
    result = current_roles[key]
    if result.nil? && of.try(:has_attribute?, :type)
      key = "#{role}_#{of.class.base_class.to_s.underscore}".to_sym
      result = current_roles[key]
    end

    block_result, result = result.is_a?(Proc) ? [ instance_exec(of, &result), false ] : [ false, result ]
    parent_role = roles_relations[key]&.[](:parent)
    (block_result || result || false) && is?(parent_role&.to_sym)
  end
  alias is_role? is?

  def is! role
    raise VerificationFailed unless is? role
  end
  alias is_role! is!

  def is_all_of? *roles
    roles.each { |role| return false unless is? role }
    true
  end

  def is_all_of! *roles
    roles.each { |role| is! role }
  end

  def family role, options = { }, &block
    old_roles_keys = current_roles.keys
    instance_eval(&block)
    new_roles = current_roles.keys - old_roles_keys
    is role, options.merge!(children: new_roles)
    new_roles.each do |new_role|
      (roles_relations[new_role] ||= { })[:parent] = role
    end
  end

  def load_roles_from_database
    Rails.cache.fetch("#{self.class.name.underscore}_#{self.id}_roles", expires_in: 1.hour) do
      assoc_roles = roles.includes(:entity_roles).to_a
      roles_include_parent = [ *assoc_roles, *assoc_roles.map(&:base_role).compact ] # TODO: 优化
      roles_include_parent.map do |role|
        options = {
            parent: role.base_role&.name,
            children: (children = role.sub_roles.pluck(:name)).present? ? children : nil
        }.delete_if { |_, v| v.blank? }
        [ role.name.to_sym, options ]
      end
    end.each { |(name, options)| is name, options }
  end

  def roles_setting
    @_current_roles, @_roles_groups, @_roles_relations = { }, { }, { }
    load_roles_from_database
  end

  def always; { when: true };  end
  def never;  { when: false }; end

  class VerificationFailed < StandardError; end
end
