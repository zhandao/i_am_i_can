require 'rails/generators'
require 'rails/generators/named_base'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module IAmICan
  module Generators
    class SetupGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      desc 'Generates migrations and models for the subject'

      source_root File.expand_path('../templates', __FILE__)

      # TODO: more readable tips
      def questions
        @ii_opts = { }
        role_class = ask("Do you want to change the class name of the role model (defaults to [#{name_c}Role])? Press Enter or input your name:")
        @ii_opts[:role_class] = role_class.blank? ? "#{name_c}Role" : role_class
        pms_class = ask("Do you want to change the class name of the permission model (defaults to [#{name_c}Permission])? Press Enter or input your name:")
        @ii_opts[:permission_class] = pms_class.blank? ? "#{name_c}Permission" : pms_class
        if yes?('Do you want to use role group? y (default) / n')
           group_class = ask("Do you want to change the class name of the role_group model (defaults to [#{name_c}RoleGroup])? Press Enter or input your name:")
           @ii_opts[:role_group_class] = group_class.blank? ? "#{name_c}RoleGroup" : group_class
        else
          @ii_opts[:without_group] = true
        end

        unless yes?('Do yo want it to save role and permission to database by default? y (default) / n')
          @ii_opts[:default_save] = false
        end
        # if @ii_opts[:default_save] != false && yes?('Don\'t you need **local** definition and assignment feature? y / n (default)')
        #   TODO
        # end
        if yes?('Do you want it to raise error when you are doing wrong definition or assignment? y / n (default)')
          @ii_opts[:strict_mode] = true
        end
        if yes?('Do you want it to auto define the role/permission which is not defined when assigning to subject? y / n (default)')
          @ii_opts[:auto_define_before] = true
        end
      end

      def setup_migrations
        migration_template 'migrations/i_am_i_can.erb', "db/migrate/#{name_u}_am_#{name_u}_can.rb"
      end

      def setup_initializer
        template 'initializers/i_am_i_can.erb', "config/initializers/#{name_u}_am_#{name_u}_can.rb"
      end

      def setup_models
        template 'models/role.erb', "app/models/#{role_u}.rb"
        template 'models/role_group.erb', "app/models/#{group_u}.rb" unless @ii_opts[:without_group]
        template 'models/permission.erb', "app/models/#{permission_u}.rb"
      end

      def tips
        puts "    Add the code below to #{name_c}:".green
        puts <<~TIPS
          has_and_belongs_to_many :stored_roles,
                                  join_table: '#{subj_role_tb}', foreign_key: '#{role_u}_id', class_name: '#{role_c}', association_foreign_key: '#{name_u}_id'

          act_as_subject
        TIPS
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def name_c; name.camelize end
      def name_u; name.underscore end
      def name_up; name_u.pluralize end

      def role_c; @ii_opts[:role_class] end
      def role_u; @ii_opts[:role_class].underscore end
      def role_up; @ii_opts[:role_class].underscore.pluralize end

      def group_c; @ii_opts[:role_group_class] end
      def group_u; @ii_opts[:role_group_class]&.underscore end
      def group_up; @ii_opts[:role_group_class]&.underscore&.pluralize end

      def permission_c; @ii_opts[:permission_class] end
      def permission_u; @ii_opts[:permission_class].underscore end
      def permission_up; @ii_opts[:permission_class].underscore.pluralize end

      def subj_role_tb; name_up + '_and_' + role_up end
      def group_role_tb; group_up + '_and_' + role_up end
      def role_pms_tb; role_up + '_and_' + permission_up end
      def group_pms_tb; group_up + '_and_' + permission_up end
    end
  end
end
