require 'i_am_i_can/role/methods'

module IAmICan
  module Role
    module Definition
      include Methods::Cls

      def have_role *roles, save: i_am_i_can.saved_by_default, which_can: [ ], obj: nil
        failed_items, preds = [ ], which_can

        roles.each do |name|
          if save
            next failed_items << name unless _to_store_role(name)
            # next failed_items << name unless _create_roles(name)
            i_am_i_can.role_model.which(name: name).can *preds, obj: obj, auto_definition: true, strict_mode: true if which_can.present?
          else
            next failed_items << name if defined_temporary_roles.key?(name)
            defined_temporary_roles[name] ||= { permissions: [ ] }
            local_role_which(name: name, can: preds, obj: obj, auto_definition: true, strict_mode: true) if which_can.present?
          end
        end

        _role_definition_result(roles, failed_items)
      end

      alias have_roles have_role
      alias has_role   have_role
      alias has_roles  have_role

      def declare_role *names, **options
        have_role *names, save: false, **options
      end

      alias declare_roles has_role

      def group_roles *members, by_name:, which_can: [ ], obj: nil
        raise Error, 'Some of members have not been defined' unless (members - defined_stored_role_names).empty?
        raise Error, "Given name #{by_name} has been used by a role" if i_am_i_can.role_model.exists?(name: by_name)
        i_am_i_can.role_group_model.find_or_create_by!(name: by_name)._members_add(name: members)
      end

      alias group_role   group_roles
      alias groups_role  group_roles
      alias groups_roles group_roles

      def have_and_group_roles *members, by_name:
        has_roles *members
        group_roles *members, by_name: by_name
      end

      alias has_and_groups_roles have_and_group_roles

      def self.extended(kls)
        kls.delegate :defined_temporary_roles, :defined_stored_roles, :defined_roles, to: kls
      end
    end
  end
end
