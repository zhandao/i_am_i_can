# frozen_string_literal: true

module IAmICan
  module Resource
    extend ActiveSupport::Concern

    included do
      # Book.that_allow(User.all, to: :read)
      # Book.that_allow(User.last, to: :write)
      scope :that_allow, -> (subject, to:) do
        stored_ids = subject.try(:new_record?) ? [ ] : subject._roles.ids
        tmp_role_ids = Array(subject).flat_map(&:temporary_roles).map(&:id).uniq
        allowed_ids = subject.i_am_i_can.role_model.where(id: (stored_ids + tmp_role_ids).uniq)
                          ._permissions.where(action: to, obj_type: self.name).pluck(:obj_id).uniq
        where(id: allowed_ids)
      end
    end
  end
end
