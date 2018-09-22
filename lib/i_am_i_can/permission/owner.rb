module IAmICan
  module Permission
    module Owner
      def has_permission *preds, obj: nil, desc: nil, save: true
        failed_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          description = desc || pms_name.to_s.tr('_', ' ')
          if save
            failed_items << pms_name unless to_store_permission(pred, obj, desc: description)
          else
            # TODO: key match
            failed_items << pms_name if local_permissions.key?(pms_name)
            local_permissions[pms_name] ||= { desc: description }
          end
        end

        raise Error, "Done, but #{failed_items} have been defined or covered" if failed_items.present?
        preds
      end

      alias has_permissions has_permission

      def to_store_permission(pred, obj, **options)
        return false if config.permission_model.exists?(pred, obj)
        config.permission_model.create!(pred: pred, **deconstruct_obj(obj), **options)
      end

      def declare_permission *preds, **options
        has_permission *preds, **options, save: false
      end

      alias declare_permissions declare_permission

      def pms_naming(pred, obj)
        obj_type, obj_id = deconstruct_obj(obj).values
        otp = "_#{obj_type}" if obj_type.present?
        oid = "_#{obj_id}" if obj_id.present?
        [pred, otp, oid].join.to_sym
      end

      def deconstruct_obj(obj)
        config.permission_model.deconstruct_obj(obj)
      end

      def local_permissions
        @local_permissions ||= { }
      end

      def stored_permission_names
        config.permission_model.all.map(&:name)
      end

      def stored_permissions
        config.permission_model.all.map { |pms| [ pms.name, pms.desc ] }.to_h
      end

      def permissions
        local_permissions.merge(stored_permissions)
      end

      def self.extended(kls)
        kls.include InstanceMethods
      end
    end

    # === End of ClassMethods ===

    module Owner::InstanceMethods
      def can *preds, obj: nil, save: true
        self.class.has_permissions *preds, obj: obj, save: save unless config.use_after_define
        failed_items = [ ]

        preds.each do |pred|
          pms_name = self.class.pms_naming(pred, obj)
          if save
            failed_items << pms_name unless stored_permissions_add(pred: pred, **self.class.deconstruct_obj(obj))
          else
            # TODO: key match
            next failed_items << pms_name unless pred.in?(self.class.permissions.keys)
            local_permissions << pms_name unless pms_name.in?(local_permissions)
          end
        end

        raise Error, "Done, but #{failed_items} have not been defined" if failed_items.present?
        preds
      end

      alias has_permission can

      def temporarily_can *preds, **options
        can *preds, save: false, **options
      end

      alias locally_can temporarily_can

      # `can? :manage, User` / `can? :manage, obj: User`
      # TODO: key match and test it
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = self.class.pms_naming(pred, obj)
        pms_name.in?(local_permission_names) || pms_name.in?(stored_permission_names)
      end

      def local_permissions
        @local_permissions ||= [ ]
      end

      alias local_permission_names local_permissions

      def stored_permission_names
        stored_permissions.map(&:name)
      end

      # TODO: show by hash
      def permissions
        local_permission_names + stored_permission_names
      end
    end
  end
end
