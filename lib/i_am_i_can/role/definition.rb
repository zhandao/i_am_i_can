module IAmICan
  module Role
    module Definition
      def have_role *roles, which_can: [ ], obj: nil, remarks: nil
        return unless roles.tap(&:flatten!).first.class.in?([ Symbol, String ])
        roles.map!(&:to_sym) ; i = i_am_i_can
        definition = _create_roles(roles.map { |role| { name: role, remarks: remarks } })

        Role.modeling(roles, i).each { |r| r.can *which_can, obj: obj, auto_definition: true } if which_can.present?
        ResultOf.roles definition, i, given: roles
      end

      %i[ have_roles has_role has_roles ].each { |aname| alias_method aname, :have_role }
    end

    def self.modeling(objs, i_am_i_can)
      return objs if objs.first.is_a?(i_am_i_can.role_model)
      objs.map { |obj| i_am_i_can.role_model.where(name: obj).first_or_initialize }
    end

    def self.extract(param_roles, i_am_i_can)
      roles = param_roles.group_by(&:class)
      instances = roles[i_am_i_can.role_model] || []
      names = roles.values_at(Symbol, String).flatten.compact.uniq.map(&:to_sym)
      [ instances, names ]
    end
  end
end
