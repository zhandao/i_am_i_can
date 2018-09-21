module IAmICan
  module Am
    def local_roles; @local_roles ||= [ ] end
    alias local_role_names local_roles

    # TODO: cache
    # TODO: default save
    def becomes_a *roles, save: false
      roles.each do |role|
        raise Error, 'This role has not been defined' unless role.in?(model_local_roles.keys)
        local_role_names << role unless role.in?(local_role_names)
        to_store_role role if save
      end
    end

    alias is_roles  becomes_a
    alias is_a_role becomes_a
    alias role_is   becomes_a
    alias roles_are becomes_a
    alias has_roles becomes_a
    alias has_role  becomes_a

    def store_role *roles
      is_roles *roles, save: true
    end

    def to_store_role name
      raise Error, "Could not find role #{name}" unless stored_roles_add(name)
    end

    def is? role
      role.to_sym.in?(local_role_names) || false
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
      (local_role_names & group_members).present?
    end

    alias in_role_group? is_in_role_group?
  end


  # === End of MainMethods ===

  module Am::SecondaryMethods
    Am.include self
  end
end
