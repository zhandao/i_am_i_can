module IAmICan
  module Role
    module Permission
      def can *names, desc: nil, save: true
        #
      end

      alias has_permission can
    end
  end
end
