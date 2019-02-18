# frozen_string_literal: true

module IAmICan
  module Subject
    module RoleQuerying

      # === Role Querying ===

      def is? role_name
        roles.find_by(name: role_name).present?
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

      def is_one_of? *role_names
        roles.where(name: role_names).present?
      end

      alias is_one_of_roles? is_one_of?

      def is_one_of! *roles
        raise VerificationFailed unless is_one_of? *roles
      end

      alias is_one_of_roles! is_one_of!

      def is_every? *role_names
        roles.where(name: role_names).count == role_names.count
      end

      alias is_every_role_in? is_every?

      def is_every! *roles
        roles.each { |role| is! role } && true
      end

      alias is_every_role_in! is_every!

      # === Group Querying ===

      def is_in_role_group? name
        group_members = i_am_i_can.role_group_model.find_by!(name: name)._roles.names
        (roles.names & group_members).present?
      end

      alias in_role_group? is_in_role_group?

      def is_in_one_of? *group_names
        group_names.each { |name| return true if is_in_role_group? name } && false
      end

      alias in_one_of? is_in_one_of?
    end
  end
end
