module IAmICan
  module Association_ClassMethods
    def has_many_temporary_roles(name: nil)
      define_method :temporary_role_names do
        # @temporary_role_names ||= [ ]
        temporary_roles.map { |role| role[:name].to_sym }
      end

      alias_method "#{name.to_s.singularize}_names", :temporary_role_names if name

      define_method :temporary_roles do
        # defined_temporary_roles.slice(*temporary_role_names)
        @temporary_roles ||= [ ]
      end

      alias_method name, :temporary_roles if name

      define_method :roles do
        temporary_roles + _roles
      end

      define_method :role_names do
        temporary_role_names + stored_role_names
      end

      # 1. defined_temporary_roles
      cattr_accessor(:defined_temporary_roles) { { } }
      # 2. To alias above by given assoc name
      singleton_class.send(:alias_method, "defined_#{name}", :defined_temporary_roles) if name

      # 3. _temporary_roles_add
      #    Add temporary roles to a user instance
      define_method "#{name.to_s.pluralize}_add" do |names|
        names -= temporary_role_names
        temporary_roles.concat((roles = i_am_i_can.role_model.where(name: names)).map(&:attributes))
        roles.names
      end
      #
      alias_method :_temporary_roles_add, "#{name.to_s.pluralize}_add"

      # 4. _temporary_roles_rmv
      #    Remove temporary roles to a user instance
      define_method "#{name.to_s.pluralize}_rmv" do |names|
        (names & temporary_role_names).each do |n|
          temporary_roles.reject! { |i| i[:name].to_sym == n }
        end
      end
      #
      alias_method :_temporary_roles_rmv, "#{name.to_s.pluralize}_rmv"

      # 5. exec
      define_method "#{name.to_s.pluralize}_exec" do |action = :assignment, names|
        send('_temporary_roles_' + (action == :assignment ? 'add' : 'rmv'), names)
      end
      #
      alias_method :_temporary_roles_exec, "#{name.to_s.pluralize}_exec"
    end
  end
end
