module IAmICan
  module Configs
    class Config
      attr_accessor :subject_class, :role_class, :role_group_class, :permission_class,
                    :auto_define_before, :strict_mode, :without_group, :default_save, :act

      def initialize(*classes)
        self.subject_class, self.role_class, self.permission_class, self.role_group_class = classes
        self.auto_define_before = false
        self.strict_mode = false
        self.without_group = false
        self.default_save = true
      end

      def subject_model
        @subject_model ||= subject_class.constantize
      end

      def role_model
        @role_model ||= role_class.constantize
      end

      def role_group_model
        @role_group_model ||= role_group_class.constantize rescue nil
      end

      def permission_model
        @permission_model ||= permission_class.constantize
      end
    end
  end
end
