module IAmICan
  module HasAnArrayOf
    def has_an_array_of obj, model: nil, field: nil,
                        prefix: nil, attrs: [ ], located_by: nil, cache_expires_in: nil, for_related_name: nil
      obj_model = model.constantize || obj.to_s.singularize.camelize.constantize
      field = field || :"#{obj.to_s.singularize}_ids"
      prefix = "#{prefix}_" if prefix

      # User.where(..).stored_roles
      define_singleton_method "#{prefix}#{obj}" do
        obj_ids = self.all.map(&field).flatten.uniq
        obj_model.where(id: obj_ids)
      end

      # user.stored_roles
      define_method "#{prefix}#{obj}" do
        obj_model.where(id: send(field))
      end

      # cached_stored_roles
      define_method "cached_#{prefix}#{obj}" do |**options|
        Rails.cache.fetch("#{self.class.name}/#{id}/#{obj}", expires_in: cache_expires_in, **options) do
          obj_model.where(id: send(field))
        end
      end

      # stored_roles_add
      define_method "#{prefix}#{obj}_add" do |locate_vals = nil, check_size: nil, **condition|
        condition = { located_by => locate_vals } if locate_vals
        obj_ids = obj_model.where(condition)&.pluck(:id)
        # will return false if it does nothing
        return false if obj_ids.blank? || (check_size && obj_ids != check_size)
        (send(field).concat(obj_ids)).uniq!
        save!
      end

      # stored_roles_rmv
      define_method "#{prefix}#{obj}_rmv" do |locate_vals = nil, **condition|
        condition = { located_by => locate_vals } if locate_vals
        obj_ids = obj_model.where(condition)&.pluck(:id)
        send("#{field}-=", obj_ids)# -= obj_ids
        save!
      end

      attrs.each do |(attr_name, attr_type)|
        # User.where(..).stored_role_names
        define_singleton_method "#{prefix}#{obj.to_s.singularize}_#{attr_name.to_s.pluralize}" do
          res = send("#{prefix}#{obj}").pluck(attr_name)
          attr_type ? res.map(&attr_type) : res
        end

        # user.stored_role_names
        define_method "#{prefix}#{obj.to_s.singularize}_#{attr_name.to_s.pluralize}" do
          res = send("#{prefix}#{obj}").pluck(attr_name)
          attr_type ? res.map(&attr_type) : res
        end
      end

      # === actions for object model ===
      obj_model.class_exec(for_related_name, self, field) do |subject_name, subject_model, related_field|
        # roles.related_users
        define_singleton_method "related_#{(subject_name || subject_model.name).underscore.pluralize}" do
          subject_model.where("#{related_field} @> ARRAY[?]::integer[]", ids)
        end

        # role.related_users
        define_method "related_#{(subject_name || subject_model.name).underscore.pluralize}" do
          subject_model.where("? = ANY (#{related_field})", self.id)
        end
      end
    end
  end
end
