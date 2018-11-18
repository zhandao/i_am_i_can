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
    end
  end
end
