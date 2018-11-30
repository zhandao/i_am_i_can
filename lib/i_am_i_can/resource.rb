module IAmICan
  module Resource
    extend ActiveSupport::Concern

    included do
      # Book.that_allow(User.all, to: :read)
      # Book.that_allow(User.last, to: :write)
      scope :that_allow, -> (subject, to:) do
        tmp_role_ids = Array(subject).flat_map(&:temporary_roles).map(&:id).uniq
        allowed_ids = subject.i_am_i_can.role_model.where(id: (subject._roles.ids + tmp_role_ids).uniq)
                          ._permissions.where(action: to, obj_type: self.name).pluck(:obj_id).uniq
        where(id: allowed_ids)
      end
    end

    class_methods do
      # def that_allow(subject)
      #   ThatAllow.new(self, subject)
      # end
    end
  end

  # class ThatAllow
  #   attr_accessor :records, :subject
  #
  #   def initialize(records, subject)
  #     self.records = records
  #     self.subject = subject
  #   end
  #
  #   def to(action)
  #   end
  # end
end
