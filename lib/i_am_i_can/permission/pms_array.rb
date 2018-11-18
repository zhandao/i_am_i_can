module IAmICan
  module Permission
    class PmsArray < ::Array
      def names
        each_with_index.map { |_, i| name_of(i) }
      end

      def get(i)
        self.class.new(self.values_at(*i))
      end

      def where(name: [], pred: nil, obj_type: nil, obj_id: nil)
        pms = names
        name.uniq.map { |n| [pms.find(n), pms.find_index(n)] if pms.find(n) }.compact.to_h
      end

      def name_of(i)
        self[i].values_at(:pred, :obj_type, :obj_id).compact.join('_').to_sym
      end
    end
  end
end
