module IAmICan
  module Subject
    module RoleQuerying

      # === Role Querying ===

      def is? role
        role.to_sym.in?(temporary_role_names) || role.to_sym.in?(stored_role_names)
      end

      alias is_role?  is?
      alias has_role? is?

      def isnt? role
      !is? role
      end

      def is! role
        raise VerificationFailed if isnt? role
        true
      end

      alias is_role!  is!
      alias has_role! is!

      def is_one_of? *roles
        roles.each { |role| return true if is? role } && false
      end

      alias is_one_of_roles? is_one_of?

      def is_one_of! *roles
        raise VerificationFailed unless is_one_of? *roles
      end

      alias is_one_of_roles! is_one_of!

      def is_every? *roles
        roles.each { |role| return false if isnt? role } && true
      end

      alias is_every_role_in? is_every?

      def is_every! *roles
        roles.each { |role| is! role } && true
      end

      alias is_every_role_in! is_every!

      # === Group Querying ===

      def is_in_role_group? name
        group_members = self.class.members_of_role_group(name)
        (role_names & group_members).present?
      end

      alias in_role_group? is_in_role_group?

      def is_in_one_of? *group_names
        group_names.each { |name| return true if is_in_role_group? name } && false
      end

      alias in_one_of? is_in_one_of?
    end
  end
end
