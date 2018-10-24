module IAmICan
  module DynamicGenerate
    extend self

    def scopes
      # Generate scopes of each specified i_am_i_can association
      #
      # scope :with_stored_roles, -> { includes(:stored_roles) }
      #
      proc do |keys|
        keys.each do |k|
          scope :"with_#{_reflect_of(k)}", ->  { includes(_reflect_of(k)) }
        end
      end
    end

    def class_reflections
      # Extend each associated querying to a class method that returns ActiveRecord::Relation
      #
      # Suppose: in UserRole model,
      #   has_and_belongs_to_many :related_users
      #
      # It will do like this:
      #   def self.related_users
      #     i_am_i_can.subject_model.with_stored_roles.where(user_roles: { id: self.ids })
      #   end
      #
      # Usage:
      #   UserRole.all.related_users
      #
      proc do
        %w[ subject role role_group permission ].each do |k|
          next unless _reflect_of(k)
          define_singleton_method _reflect_of(k) do
            model = i_am_i_can.send("#{k}_model")
            raise NoMethodError unless (reflect_name = model._reflect_of(i_am_i_can.act))
            model.send("with_#{reflect_name}").where(
                self.name.underscore.pluralize => { id: self.ids }
            )
          end
        end
      end
    end

    def assignment_helpers
      # Generate 4 methods for each Content of Assignment
      #
      # Example for a subject model called User, which `has_and_belongs_to_many :stored_roles`.
      # You call this proc by given contents [:role], then:
      #
      # 1. _stored_roles_add
      #   Add roles to a user instance
      #
      # 2. _stored_roles_rmv
      #   Remove roles to a user instance
      #
      # 3. stored_role_names
      #   Get names of stored_roles of a user instance
      #
      # 4. self.stored_role_names
      #   Get names of stored_roles of User ActiveRecord::Relation
      #
      proc do |contents|
        contents.each do |content|
          # TODO: refactoring
          define_method "_#{_reflect_of(content)}_add" do |locate_vals = nil, check_size: nil, **condition|
            condition = { name: locate_vals } if locate_vals
            assoc = send("_#{content.pluralize}")
            records = i_am_i_can.send("#{content}_model").where(condition).where.not(id: assoc.ids)
            # will return false if it does nothing
            return false if records.blank? || (check_size && records.count != check_size)
            assoc << records
          end

          alias_method :"_stored_#{content.pluralize}_add", :"_#{_reflect_of(content)}_add"

          define_method "_#{_reflect_of(content)}_rmv" do |locate_vals = nil, check_size: nil, **condition|
            condition = { name: locate_vals } if locate_vals
            assoc = send("_#{content.pluralize}")
            records = i_am_i_can.send("#{content}_model").where(id: assoc.ids, **condition)
            # will return false if it does nothing
            return false if records.blank? || (check_size && records.count != check_size)
            assoc.destroy(records)
          end

          alias_method :"_stored_#{content.pluralize}_rmv", :"_#{_reflect_of(content)}_rmv"

          define_method "#{_reflect_of(content).to_s.singularize}_names" do
            send("_#{content.pluralize}").map(&:name).map(&:to_sym)
          end

          alias_method :"stored_#{content}_names", :"#{_reflect_of(content).to_s.singularize}_names"

          define_singleton_method "#{_reflect_of(content).to_s.singularize}_names" do
            all.flat_map { |user| user.send("#{_reflect_of(content).to_s.singularize}_name") }.uniq
          end

          singleton_class.send(:alias_method, :"stored_#{content}_names", :"#{_reflect_of(content).to_s.singularize}_names")
        end
      end
    end
  end
end
