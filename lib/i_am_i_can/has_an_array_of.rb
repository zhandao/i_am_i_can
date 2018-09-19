module IAmICan
  module HasAnArrayOf
    def has_an_array_of obj, model: nil, field: nil, prefix: nil, attrs: [ ]
      obj_model = model.constantize || obj.to_s.singularize.camelize.constantize
      field = field || :"#{obj.to_s.singularize}_ids"
      prefix = "#{prefix}_" if prefix

      # stored_roles
      define_method "#{prefix}#{obj}" do
        obj_model.where(id: field)
      end

      # stored_roles_add
      define_method "#{prefix}#{obj}_add" do |condition|
        rid = obj_model.find_by(condition)&.id
        return false unless rid
        (send(field).push(rid)).uniq! and save!
      end

      # stored_roles_rmv
      define_method "#{prefix}#{obj}_rmv" do |condition|
        rid = obj_model.find_by(condition)&.id
        return false unless rid
        send(field).delete(rid) and save!
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
