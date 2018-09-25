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

      def questions
        @ii_opts = { }
        unless yes?('Do you want to use role group?')
          @ii_opts[:without_group] = true
        end
        unless yes?('Do yo want it to save role and permission to database by default?')
          @ii_opts[:default_save] = false
        end
        if yes?('Do you want it to raise error when you are doing wrong definition or assignment?')
          @ii_opts[:strict_mode] = true
        end
        if yes?('Do you want it to define the role/permission which is not defined when assigning to subject?')
          @ii_opts[:auto_define_before] = true
        end
      end

      def setup_migrations
        dest_prefix = 'db/migrate/i_am_i_can_'
        migration_template 'migrations/add_to_subject.erb', "#{dest_prefix}add_role_ids_to_#{name.underscore}.rb"
        migration_template 'migrations/role.erb', "#{dest_prefix}create_#{name.underscore}_roles.rb"
        migration_template 'migrations/role_group.erb', "#{dest_prefix}create_#{name.underscore}_role_groups.rb" unless @ii_opts[:without_group]
        migration_template 'migrations/permission.erb', "#{dest_prefix}create_#{name.underscore}_permissions.rb"
      end

      def setup_models
        template 'models/role.erb', "app/models/#{name.underscore}_role.rb"
        template 'models/role_group.erb', "app/models/#{name.underscore}_role_group.rb" unless @ii_opts[:without_group]
        template 'models/permission.erb', "app/models/#{name.underscore}_permission.rb"
      end

      def tip
        options = ' ' + @ii_opts.to_s[2..-2].gsub('=>', ': ').gsub(', :', ', ') if @ii_opts.keys.present?
        puts 'Please add this line to your subject model:'.red
        puts "    act_as_i_am_i_can#{options}".red
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
