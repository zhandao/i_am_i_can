require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'

module IAmICan
  module Role
    extend ActiveSupport::Concern

    class_methods do
      def which(name:, **conditions)
        find_by!(name: name, **conditions)
      end
    end

    included do
    end
  end
end
