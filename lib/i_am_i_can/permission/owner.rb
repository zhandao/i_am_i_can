module IAmICan
  module Permission
    module Owner
      def has_permission *names, desc: nil, save: true
        names.map do |name|
          description = desc || name.to_s.humanize
          to_store_permission(name, desc: description) if save
          next "Permission #{name} has been defined" if local_permissions.key?(name)
          local_permissions[name] ||= { desc: description } && name
        end
      end

      alias can has_permission
    end

    # === End of MainMethods ===

    module Owner::SecondaryMethods
      def local_permissions
        @local_permissions ||= { }
      end

      def stored_permission_names
        ii_config.permission_model.pluck(:name).map(&:to_sym)
      end

      def stored_permissions
        ii_config.permission_model.all.map { |role| [ role.name.to_sym, role.desc ] }.to_h
      end

      def to_store_permission(name, **options)
        return "Permission #{name} has been stored" if ii_config.permission_model.exists?(name: name)
        ii_config.permission_model.create!(name: name, **options)
      end

      Owner.include self
    end
  end
end
