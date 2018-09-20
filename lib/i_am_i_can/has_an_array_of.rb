module IAmICan
  module HasAnArrayOf
    def has_an_array_of obj, model: nil, field: nil, prefix: nil, attrs: [ ], located_by: nil
      obj_model = model.constantize || obj.to_s.singularize.camelize.constantize
      field = field || :"#{obj.to_s.singularize}_ids"
      prefix = "#{prefix}_" if prefix

      # stored_roles
      define_method "#{prefix}#{obj}" do
        obj_model.where(id: send(field))
      end

      # stored_roles_add
      define_method "#{prefix}#{obj}_add" do |value = nil, check_size: nil, **condition|
        condition = { located_by => value } if value
        obj_ids = obj_model.where(condition)&.pluck(:id)
        return false if obj_ids.blank? || (check_size && obj_ids != check_size)
        (send(field).concat(obj_ids)).uniq!
        save!
      end

      # stored_roles_rmv
      define_method "#{prefix}#{obj}_rmv" do |value = nil, **condition|
        condition = { located_by => value } if value
        obj_ids = obj_model.where(condition)&.pluck(:id)
        send("#{field}-=", obj_ids)# -= obj_ids
        save!
      end

      attrs.each do |attr|
        # stored_role_names
        define_method "#{prefix}#{obj.to_s.singularize}_#{attr.to_s.pluralize}" do
          send("#{prefix}#{obj}").pluck(attr)
        end
      end
    end
  end
end
