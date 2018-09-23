module IAmICan
  module Permission
    class PArray < ::Array
      attr_accessor :pms

      def matched?(pms_name)
        return false if self.blank?
        self.pms = pms_name.to_sym
        found? || covered?
      end

      def found?
        pms.in? self
      end

      def covered?
        pred, obj_type, obj_id = pms.to_s.split('_')
        pred.to_sym.in?(self) || :"#{pred}_#{obj_type}".in?(self)
      end
    end
  end
end
