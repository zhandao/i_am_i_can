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
      #
      # Generate methods for each Content of Assignment
      #
      # Example for a subject model called User, which `has_and_belongs_to_many :stored_roles`.
      # You call the proc below by given contents [:role], then:
      #
      proc { |contents| contents.each do |content|
        content_cls = i_am_i_can.send("#{content}_class")
        _plural = '_' + content.to_s.pluralize

        # 1. _stored_roles_add([UserRole.which(name: :master)], { name: :admin })
        #   Add roles to a user instance
        #   # In the case of permission assignment:
        #   #    _stored_permissions_add(pred: [:read, :write], obj_type: 'Book', obj_id: 1)
        #
        define_method "_#{_reflect_of(content)}_add" do |instances = [ ], **conditions|
          collection = send(_plural)
          query_result = content_cls.constantize.where(conditions).where.not(id: collection.ids) if conditions.present?
          objects = [*(query_result || [ ]), *(instances - collection)].uniq
          collection << objects
          objects
        end

        # 2. _stored_roles_rmv
        #   Remove roles to a user instance
        #
        define_method "_#{_reflect_of(content)}_rmv" do |instances = [ ], **conditions|
          collection = send(_plural)
          query_result = content_cls.constantize.where(id: collection.ids, **conditions) if conditions.present?
          objects = [*(query_result || [ ]), *(instances & collection)].uniq
          collection.destroy(objects)
          objects
        end

        # _stored_roles_exec
        #   Add / Remove (by passing action :cancel) roles to a user instance
        define_method "_#{_reflect_of(content)}_exec" do |action = :assignment, instances = [ ], **conditions|
          collection = send(_plural)
          if conditions.present? && action == :assignment
            query_result = content_cls.constantize.where(conditions).where.not(id: collection.ids)
          elsif conditions.present? && action == :cancel
            query_result = content_cls.constantize.where(id: collection.ids, **conditions)
          end
          objects = [*(query_result || [ ]), *(instances - collection)].uniq
          action == :assignment ? collection << objects : collection.destroy(objects)
          objects
        end


        stored_content_names = "#{_reflect_of(content).singularize}_names"

        # 3. stored_role_names
        #   Get names of stored_roles of a user instance
        #
        define_method stored_content_names do
          send(_plural).map(&:name).map(&:to_sym)
        end
        #
        alias_method "stored_#{content}_names", stored_content_names

        # 4. self.stored_role_names
        #   Get names of stored_roles of User ActiveRecord::Relation
        #
        define_singleton_method stored_content_names do
          all.flat_map { |user| user.send("#{_reflect_of(content).to_s.singularize}_name") }.uniq
        end
        #
        singleton_class.send(:alias_method, "stored_#{content}_names", stored_content_names)

        next if i_am_i_can.disable_temporary

        # 5. _temporary_roles_add
        #    Add temporary roles to a user instance
        define_method "_temporary#{_plural}_add" do |names|
          object_names = (names & self.class.defined_role_names) - temporary_role_names
          temporary_role_names.concat(object_names)
          object_names
        end

        # 6. _temporary_roles_rmv
        #    Remove temporary roles to a user instance
        define_method "_temporary#{_plural}_rmv" do |names|
          @temporary_role_names -= object_names = names & temporary_role_names
          object_names
        end

        define_method "_temporary#{_plural}_exec" do |action = :assignment, names|
          send("_temporary#{_plural}_" + (action == :assignment ? 'add' : 'rmv'), names)
          end
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
        content_cls = i_am_i_can.send("#{content}_class")
        _plural = '_' + content.to_s.pluralize

        # 1. _create_roles
        #    Define and store roles of Subject
        define_singleton_method "_create#{_plural}" do |objects|
          content_cls.constantize.create(objects)
              .reject {|record| record.new_record? }
        end

        # 2. _define_tmp_roles
        #    define temporary roles of Subject
        define_singleton_method "_define_tmp#{_plural}" do |objects|
          definition = send("defined_temporary#{_plural}")
          object_names = objects - definition.keys
          definition.merge!(object_names.map { |name| [name, { permissions: [ ] }] }.to_h)
          object_names
        end
      end }
    end
  end
end
