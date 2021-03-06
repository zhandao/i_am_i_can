# frozen_string_literal: true

module IAmICan
  module Permission
    module Definition
      def have_permission *actions, obj: nil, remarks: nil
        return unless actions.tap(&:flatten!).first.class.in?([ Symbol, String ])
        objs = obj ? Array(obj) : [nil]
        permissions = actions.product(objs).map { |(p, o)| { action: p, **deconstruct_obj(o), remarks: remarks } }
        definition = _create_permissions(permissions)
        ResultOf.permissions definition, i_am_i_can, given: permissions.map { |pms| pms.values.compact.join('_').to_sym }
      end

      %i[ have_permissions has_permission has_permissions ].each { |aname| alias_method aname, :have_permission }

      def deconstruct_obj(obj)
        i_am_i_can.permission_model.deconstruct_obj(obj)
      end

      def self.extended(kls)
        kls.delegate :deconstruct_obj, to: kls
      end
    end
  end
end
