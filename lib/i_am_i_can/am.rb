module IAmICan
  module Am
    # TODO: cache
    def becomes_a *roles, save: true
      self.class.has_roles *roles, save: save unless ii_config.use_after_define
      failed_items = [ ]

      roles.each do |role|
        if save
          failed_items << role unless stored_roles_add(role)
        else
          next failed_items << role unless role.in?(model_roles.keys)
          local_roles << role unless role.in?(local_roles)
        end
      end
      raise Error, "Done, but #{failed_items} have not been defined" if failed_items.present?
      roles
    end

    alias is_roles  becomes_a
    alias is_a_role becomes_a
    alias role_is   becomes_a
    alias roles_are becomes_a
    alias has_roles becomes_a
    alias has_role  becomes_a

    def temporarily_is *roles
      becomes_a *roles, save: false
    end

    alias locally_is temporarily_is

    def is? role
      role.to_sym.in?(local_role_names) || role.to_sym.in?(stored_role_names)
    end

    alias is_role? is?

    def is_in_role_group? name
      group_members = self.class.members_of_role_group(name)
      (roles & group_members).present?
    end

    alias in_role_group? is_in_role_group?
  end


  # === End of MainMethods ===

  module Am::SecondaryMethods
    def local_roles
      @local_roles ||= [ ]
    end

    alias local_role_names local_roles

    def roles
      local_roles + stored_role_names
    end

    alias role_names roles

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
