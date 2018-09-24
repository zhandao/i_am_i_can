require 'i_am_i_can/role/helpers'

module IAmICan
  module Role
    module Definition
      include Helpers::Cls

      def have_role *names, desc: nil, save: true, which_can: [ ], obj: nil
        failed_items, preds = [ ], which_can

        names.each do |name|
          description = desc || name.to_s.humanize
          if save
            next failed_items << name unless _to_store_role(name, desc: description)
            ii_config.role_model.which(name: name).can *preds, obj: obj, auto_define_before: true, strict_mode: true if which_can.present?
          else
            next failed_items << name if defined_local_roles.key?(name)
            defined_local_roles[name] ||= { desc: description, permissions: [ ] }
            local_role_which(name: name, can: preds, obj: obj, auto_define_before: true, strict_mode: true) if which_can.present?
          end
        end

        _role_definition_result(names, failed_items)
      end

      alias have_roles have_role
      alias has_role   have_role
      alias has_roles  have_role

      def declare_role *names, **options
        has_role *names, save: false, **options
      end

      alias declare_roles has_role

      def group_roles *members, by_name:, which_can: [ ], obj: nil
        raise Error, 'Some of members have not been defined' unless (members - defined_stored_role_names).empty?
        raise Error, "Given name #{by_name} has been used by a role" if ii_config.role_model.exists?(name: by_name)
        ii_config.role_group_model.find_or_create_by!(name: by_name).members_add(members)
      end

      alias group_role   group_roles
      alias groups_role  group_roles
      alias groups_roles group_roles

      def have_and_group_roles *members, by_name:
        has_roles *members
        group_roles *members, by_name: by_name
      end

      alias has_and_groups_roles have_and_group_roles

      # permission assignment locally for local role
      # User.local_role_which(name: :admin, can: :fly)
      #   same effect to: UserRole.new(name: :admin).temporarily_can :fly
      def local_role_which(name:, can:, obj: nil, **options)
        ii_config.role_model.new(name: name).temporarily_can *Array(can), obj: obj, **options
      end

      def self.extended(kls)
        kls.delegate :defined_local_roles, :defined_stored_roles, :defined_roles, to: kls
      end
    end

    # === End of MainMethods ===

    module Definition::SecondaryMethods
      def defined_local_roles
        @local_roles ||= { }
      end

      def defined_stored_role_names
        ii_config.role_model.pluck(:name).map(&:to_sym)
      end

      def defined_stored_roles
        ii_config.role_model.all.map { |role| [ role.name.to_sym, role.desc ] }.to_h
      end

      def defined_roles
        defined_local_roles.deep_merge(defined_stored_roles)
      end

      def defined_role_group_names
        ii_config.role_group_model.pluck(:name).map(&:to_sym)

      end

      def defined_role_groups
        ii_config.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym) ] }.to_h
      end

      def members_of_role_group name
        ii_config.role_group_model.find_by!(name: name).member_names
      end

      Definition.include self
    end
  end
end
