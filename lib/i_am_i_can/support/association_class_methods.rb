module IAmICan
  module Association_ClassMethods
    def has_many_temporary_roles(name: nil)
      define_method :temporary_roles do
        @temporary_roles ||= [ ]
      end
      #
      alias_method name, :temporary_roles if name

      define_method :valid_temporary_roles do
        i_am_i_can.role_model.where(id: temporary_roles.map(&:id))
      end

      raise "Do not set the role association name to `roles` in #{self.class.name} model" if respond_to?(:roles)
      define_method :roles do
        ids = (temporary_roles.map(&:id) + _roles.ids).uniq
        i_am_i_can.role_model.where(id: ids)
      end

      define_method :temporary_role_names do
        temporary_roles.map(&:name).map(&:to_sym)
      end
      #
      alias_method "#{name.to_s.singularize}_names", :temporary_role_names if name

      define_method :_temporary_roles_add do |names|
        names -= temporary_role_names
        temporary_roles.concat(roles = i_am_i_can.role_model.where(name: names))
        roles.names
      end

      define_method :_temporary_roles_rmv do |names|
        (names & temporary_role_names).each do |n|
          temporary_roles.reject! { |i| i.name.to_sym == n }
        end
      end

      define_method :_temporary_roles_exec do |action = :assign, names|
        send('_temporary_roles_' + (action == :assign ? 'add' : 'rmv'), names)
      end
    end
  end
end
