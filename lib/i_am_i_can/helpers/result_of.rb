module IAmICan
  module ResultOf
    module Roles
      def roles assignment, given: [ ]
        ResultOf.(assignment, given,
                msg_prefix: 'Role Assignment: ',
                fail_msg: 'have not been defined or have been repeatedly assigned!'
        )
      end

      ResultOf.include self
    end

    extend self

    def call(assignment, given, msg_prefix:, fail_msg:)
      instances, names = given
      assignment = assignment.map(&:name).map(&:to_sym) unless assignment.first.is_a?(Symbol)
      to_be_assigned_names = (instances.map(&:name).map(&:to_sym) + names).uniq
      failed_items = to_be_assigned_names - assignment

      msg = msg_prefix + (assignment.blank? ? 'do nothing' : "#{assignment} DONE")
      msg << "; And #{failed_items} #{fail_msg}" if failed_items.present?

      if Configs.take.strict_mode && failed_items.present?
        raise Error, msg
      else
        puts fail_msg || prefix unless ENV['ITEST']
        assignment
      end
    end
  end
end
