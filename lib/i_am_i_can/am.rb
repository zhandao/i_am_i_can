module IAmICan
  module Am
    def local_roles; @local_roles ||= [ ] end
    alias local_role_names local_roles

    # TODO: cache
    # TODO: default save
    def becomes_a *roles, save: false
      roles.each do |role|
        if save
          to_store_role role
        else
          raise Error, "This role #{role} has not been defined" unless role.in?(model_roles.keys)
          local_roles << role unless role.in?(local_roles)
        end
      end
    end

    alias is_roles  becomes_a
    alias is_a_role becomes_a
    alias role_is   becomes_a
    alias roles_are becomes_a
    alias has_roles becomes_a
    alias has_role  becomes_a

    def is? role
      role.to_sym.in?(local_role_names) || role.to_sym.in?(stored_role_names)
    end

    alias is_role? is?

    def is_in_role_group?(name)
      group_members = self.class.members_of_role_group(name)
      (local_role_names & group_members).present?
    end

    alias in_role_group? is_in_role_group?
  end


  # === End of MainMethods ===

  module Am::SecondaryMethods
    def store_role *roles
      is_roles *roles, save: true
    end

    def to_store_role name
      raise Error, "Could not find role #{name}" unless stored_roles_add(name)
    end

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

    Am.include self
  end
end
