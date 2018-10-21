require 'i_am_i_can/configs/configs'

module IAmICan
  module Configurable
    extend ActiveSupport::Concern

    class_methods do
      def i_am_i_can
        Configs.get(self.name)
      end
    end

    included do
      def i_am_i_can
        Configs.get(self.class.name)
      end
    end
  end
end
