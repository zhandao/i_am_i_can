# frozen_string_literal: true

module IAmICan
  module Subject
    module RoleQuerying

      # === Role Querying ===

      def is? role_name, with_tmp: true
        role_id = i_am_i_can.role_model.find_by(name: role_name)&.id
        return false unless role_id
        get_roles(with_tmp: with_tmp).exists?(id: role_id)
      end

      alias is_role?  is?
      alias has_role? is?

      def isnt? role_name, with_tmp: true
      !is? role_name, with_tmp: with_tmp
      end

      def is! role_name, with_tmp: true
        raise VerificationFailed if isnt? role_name, with_tmp: with_tmp
        true
      end

      alias is_role!  is!
      alias has_role! is!

      def is_one_of? *role_names, with_tmp: true
        role_ids = i_am_i_can.role_model.where(name: role_names).ids
        return false if role_ids.blank?
        get_roles(with_tmp: with_tmp).exists?(id: role_ids)
      end

      alias is_one_of_roles? is_one_of?

      def is_one_of! *role_names, with_tmp: true
        raise VerificationFailed unless is_one_of? *role_names, with_tmp: with_tmp
        true
      end

      alias is_one_of_roles! is_one_of!

      def is_every? *role_names, with_tmp: true
        role_ids = i_am_i_can.role_model.where(name: role_names).ids
        return false if role_ids.size != role_names.size
        get_roles(with_tmp: with_tmp).where(id: role_ids).size == role_names.size
      end

      alias is_every_role_in? is_every?

      def is_every! *role_names, with_tmp: true
        raise VerificationFailed unless is_every?(*role_names, with_tmp: true)
        true
      end

      alias is_every_role_in! is_every!

      # === Group Querying ===

      def is_in_role_group? name
        group_members = i_am_i_can.role_group_model.find_by!(name: name)._roles.names
        (get_roles.names & group_members).present?
      end

      alias in_role_group? is_in_role_group?

      def is_in_one_of? *group_names
        group_names.each { |name| return true if is_in_role_group? name } && false
      end

      alias in_one_of? is_in_one_of?
    end
  end
end
