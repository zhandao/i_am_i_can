module IAmICan
  module Resource
    extend ActiveSupport::Concern

    included do
      # Book.that_allow(User.all, to: :read)
      # Book.that_allow(User.last, to: :write)
      scope :that_allow, -> (subject, to:) do
        allowed_ids = subject._roles._permissions.where(pred: to, obj_type: self.name).pluck(:obj_id).uniq
        allowed_ids += Array(subject).map(&:permissions_of_temporary_roles).map { |name| name.to_s.split('_')[2].to_i }.compact.uniq
        where(id: allowed_ids)
      end
    end

    class_methods do
      # def that_allow(subject)
      #   ThatAllow.new(sel、f, subject)
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
  #   def to(pred)
  #     allowed_ids = subject._roles._permissions.where(pred: pred, obj_type: records.name).pluck(:obj_id).uniq
  #     allowed_ids += Array(subject).map(&:permissions_of_temporary_roles).map { |name| name.to_s.split('_')[2].to_i }.compact.uniq
  #     records.where(id: allowed_ids)
  #   end
  # end
end
