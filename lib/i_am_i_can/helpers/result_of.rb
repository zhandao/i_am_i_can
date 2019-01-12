module IAmICan
  module ResultOf
    module Role
      def roles definition, i_am_i_can, given: [ ]
        ResultOf.(definition, [ [], given ], config: i_am_i_can,
                msg_prefix: 'Role Definition: ',
                fail_msg: 'have been used by other roles!'
        )
      end

      def role assignment, i_am_i_can, given: [ ]
        ResultOf.(assignment, given, config: i_am_i_can,
                msg_prefix: 'Role Assignment: ',
                fail_msg: 'have not been defined or have been repeatedly assigned!'
        )
      end

      ResultOf.include self
    end

    module RoleGroup
      def members assignment, i_am_i_can, given: [ ]
        ResultOf.(assignment, given, config: i_am_i_can,
                msg_prefix: 'Role Grouping: ',
                fail_msg: 'have not been defined!'
        )
      end

      ResultOf.include self
    end

    module Permission
      def permissions definition, i_am_i_can, given: [ ]
        ResultOf.(definition, [ [], given ], config: i_am_i_can,
                msg_prefix: 'Permission Definition: ',
                fail_msg: 'have been used by other permissions!'
        )
      end

      def permission assignment, i_am_i_can, given: [ ]
        ResultOf.(assignment, given, config: i_am_i_can,
                msg_prefix: 'Permission Assignment: ',
                fail_msg: 'have not been defined or have been repeatedly assigned!'
        )
      end

      ResultOf.include self
    end

    def call(assignment, given, msg_prefix:, fail_msg:, config:)
      instances, names = given
      instances.map!(&:name).map!(&:to_sym)
      assignment = assignment.map(&:name).map(&:to_sym) unless assignment.first.is_a?(Symbol)

      to_be_assigned_names = (instances + names).uniq
      failed_items = to_be_assigned_names - assignment

      msg = msg_prefix + (assignment.blank? ? 'do nothing' : "#{assignment} DONE")
      msg << "; And #{failed_items} #{fail_msg}" if failed_items.present?

      if config.strict_mode && failed_items.present?
        raise Error, msg
      else
        Rails.logger.info("  * #{msg}".green) unless ENV['ITEST']
        assignment
      end
    end

    extend self
  end
end
