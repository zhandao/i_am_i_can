module IAmICan
  module Role
    module Definition
      def have_role *roles, save: i_am_i_can.saved_by_default, which_can: [ ], obj: nil
        roles.map!(&:to_sym) ; i = i_am_i_can
        definition = save \
          ? _create_roles(roles.map { |role| { name: role } }) \
          : _define_tmp_roles(roles)

        Role.modeling(definition, i).each { |r| r.can *which_can, obj: obj, auto_definition: true } if which_can.present?
        ResultOf.roles definition, i, given: roles
      end

      %i[ have_roles has_role has_roles ].each { |aname| alias_method aname, :have_role }

      # TODO: rename
      def declare_role *names, **options
        have_role *names, save: false, **options
      end

      alias declare_roles has_role
    end

    def self.modeling(objs, i_am_i_can)
      return objs if objs.first.is_a?(i_am_i_can.role_model)
      objs.map { |obj| i_am_i_can.role_model.new(name: obj) }
    end

    def self.extract(param_roles, i_am_i_can)
      roles = param_roles.group_by(&:class)
      instances = roles[i_am_i_can.role_model] || []
      names = roles.values_at(Symbol, String).flatten.compact.uniq.map(&:to_sym)
      [ instances, names ]
    end
  end
end
