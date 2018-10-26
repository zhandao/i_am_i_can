module IAmICan
  module Helpers
    extend self

    def role
      proc do |role|
        next role.to_sym if role.is_a?(String) || role.is_a?(Symbol)
        next role.name if role.is_a?(i_am_i_can.role_model)
        # raise error
      end
    end
  end
end
