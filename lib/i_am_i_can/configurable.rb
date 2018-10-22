require 'i_am_i_can/configs/configs'

module IAmICan
  module Configurable
    extend ActiveSupport::Concern

    class_methods do
      def i_am_i_can
        Configs.get(self.name)
      end

      def _reflect_of_ii(key)
        _name = i_am_i_can.send("#{key}_class")
        reflections.each do |name, reflection|
          return name if reflection.class_name == _name
        end; nil
      end
    end

    included do
      def i_am_i_can
        Configs.get(self.class.name)
      end
    end
  end
end
