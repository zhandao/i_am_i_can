module IAmICan
  module Association_ClassMethods
    def has_many_temporary_roles(name: nil)
      disable_temporary = Configs.get(self.name).disable_temporary
      no_method = -> { raise NoMethodError, 'You have set the temporary feature to disable.' }

      define_method :temporary_role_names do
        no_method.call if disable_temporary
        @temporary_role_names ||= [ ]
      end

      alias_method "#{name.to_s.singularize}_names", :temporary_role_names if name

      define_method :temporary_roles do
        no_method.call if disable_temporary
        defined_temporary_roles.slice(*temporary_role_names)
      end

      alias_method name, :temporary_roles if name

      # TODO
      define_method :roles do
        temporary_role_names + stored_role_names
      end

      return if disable_temporary
      # 1. defined_temporary_roles
      cattr_accessor(:defined_temporary_roles) { { } }
      # 2. To alias above by given assoc name
      singleton_class.send(:alias_method, "defined_#{name}", :defined_temporary_roles) if name
    end
  end
end
