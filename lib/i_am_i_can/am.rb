module IAmICan
  module Am
    def roles; @_roles ||= [ ] end

    def is *roles, save: false
      return roles.each { |role| is role, save: save } unless roles.size == 1

      role = roles.first.to_sym
      raise Error, 'This role has not been defined.' unless role.in?(model_roles.keys)
      # TODO: save
      self.roles << role unless role.in?(self.roles)
    end

    alias add_role  is
    alias add_roles is

    def is? role
      roles_setting # TODO: 优化
      role.to_sym.in?(roles) || false
    end

    alias is_role? is?

    def isnt? role
      !is? role
    end

    def is! role
      raise VerificationFailed if isnt? role
      true
    end

    alias is_role! is!

    def is_every? *roles
      roles.each { |role| return false if isnt? role } && true
    end

    alias is_every_role_in? is_every?

    def is_every! *roles
      roles.each { |role| is! role } && true
    end

    alias is_every_role_in! is_every!

    def is_in_role_group?(name)
      group_members = self.class.members_of_role_group(name)
      (roles & group_members).present?
    end

    alias in_role_group? is_in_role_group?

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
      load_roles_from_database
    end
  end
end