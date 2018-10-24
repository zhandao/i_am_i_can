module IAmICan
  module Resource
    extend ActiveSupport::Concern

    class_methods do
      # Book.that_allow(User.all).to(:read)
      # Book.that_allow(User.last).to(:write)
      def that_allow(subject)
        ThatAllow.new(self, subject)
      end
    end
  end

  class ThatAllow
    attr_accessor :records, :subject

    def initialize(records, subject)
      self.records = records
      self.subject = subject
    end

    def to(pred)
      allowed_ids = subject._roles._permissions.where(pred: pred, obj_type: records.name).pluck(:obj_id).uniq
      records.where(id: allowed_ids)
    end
  end
end
