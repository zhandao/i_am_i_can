require 'i_am_i_can/permission/methods'

module IAmICan
  module Permission
    module Definition
      include Methods::Cls

      def have_permission *preds, obj: nil
        permissions = preds.product(Array[obj]).map { |(p, o)| { pred: p, **deconstruct_obj(o) } }
        definition = _create_permissions(permissions)
        ResultOf.roles definition, i_am_i_can, given: permissions.map { |pms| pms.values.compact.join('_').to_sym }
      end

      %i[ have_permissions has_permission has_permissions ].each { |aname| alias_method aname, :have_permission }

      def self.extended(kls)
        kls.delegate :deconstruct_obj, to: kls
      end
    end
  end
end
