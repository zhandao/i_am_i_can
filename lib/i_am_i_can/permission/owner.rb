module IAmICan
  module Permission
    module Owner
      def has_permission *names, desc: nil, save: true
        names.map do |name|
          description = desc || name.to_s.humanize
          if save
            to_store_permission(name, desc: description)
          else
            next "Permission #{name} has been defined" if local_permissions.key?(name)
            local_permissions[name] ||= { desc: description } && name
          end
        end
      end

      alias has_permissions has_permission

      def local_permissions
        @local_permissions ||= { }
      end

      def stored_permission_names
        config.permission_model.pluck(:name).map(&:to_sym)
      end

      def stored_permissions
        config.permission_model.all.map { |role| [ role.name.to_sym, role.desc ] }.to_h
      end

      def to_store_permission(name, **options)
        return "Permission #{name} has been stored" if config.permission_model.exists?(name: name)
        config.permission_model.create!(name: name, **options)
      end

      def extended(kls)
        kls.include InstanceMethods
      end
    end

    # === End of ClassMethods ===

    module Owner::InstanceMethods
      def can *names, save: true
        self.class.has_permissions *names, save: save unless config.use_after_define
      end

      def can?
        #
      end
    end
  end
end
