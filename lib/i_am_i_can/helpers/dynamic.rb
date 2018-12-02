module IAmICan
  module Dynamic
    extend self

    def scopes
      #
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
      #
      # Extend each associated querying to a class method that returns ActiveRecord::Relation
      #
      # Suppose: in UserRole model,
      #   has_and_belongs_to_many :related_users
      #
      # It will do like this:
      #   def self.related_users
      #     User.with_stored_roles.where(user_roles: { id: self.ids })
      #   end
      #
      # Usage:
      #   UserRole.all.related_users
      #
      proc do
        %w[ subject role role_group permission ].each do |k|
          next if _reflect_of(k).blank?
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
      #
      # Generate methods for each Content of Assignment
      #
      # Example for a subject model called User, which `has_and_belongs_to_many :stored_roles`.
      # You call the proc below by given contents [:role], then:
      #
      proc { |contents| contents.each do |content|
        content_cls = i_am_i_can.send("#{content}_class") rescue next
        _plural = '_' + content.to_s.pluralize

        # _stored_roles_exec
        #   Add / Remove (by passing action :cancel) roles to a user instance
        define_method "_#{_reflect_of(content)}_exec" do |action = :assignment, instances = [ ], **conditions|
          collection = send(_plural)
          if conditions.present? && action == :assignment
            # Role.where(name: [...]).where.not(id: roles.ids)
            query_result = content_cls.constantize.where(conditions).where.not(id: collection.ids)
          elsif conditions.present? && action == :cancel
            # Role.where(id: roles.ids, name: [...])
            query_result = content_cls.constantize.where(id: collection.ids, **conditions)
          end

          objects = [*(query_result || [ ]), *(instances - collection)].uniq
          action == :assignment ? collection << objects : collection.destroy(objects)
          objects
        end
        #
        alias_method "_stored#{_plural}_exec", "_#{_reflect_of(content)}_exec"
      end }
    end

    def definition_helpers
      #
      # Generate class methods for each Content of Definition
      #
      # Example for a subject model called User,
      #   which `has_many_temporary_roles` and `has_and_belongs_to_many :stored_roles`.
      # You call the proc below by given contents [:role], then:
      #
      proc { |contents| contents.each do |content|
        content_cls = i_am_i_can.send("#{content}_class") rescue next
        _plural = '_' + content.to_s.pluralize

        # _create_roles
        #    Define and store roles of Subject
        define_singleton_method "_create#{_plural}" do |objects|
          # Role.create([{ name: .. }]).reject { the roles that validation failed }
          content_cls.constantize.create(objects)
              .reject {|record| record.new_record? }
        end
      end }
    end
  end
end
