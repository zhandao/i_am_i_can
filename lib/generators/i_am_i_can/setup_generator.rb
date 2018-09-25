module IAmICan
  module Generators
    class SetupGenerator < Rails::Generators::NamedBase
      desc 'Generates migrations and models for the subject'

      source_root File.expand_path('../templates', __FILE__)

      def questions
        @options = { }
        unless yes?('Do you want to use role group?')
          @options[:without_group] = true
        end
        unless yes?('Do yo want it to save role and permission to database?')
          @options[:default_save] = false
        end
        if yes?('Do you want it to raise error when yu are doing wrong definition or assignment?')
          @options[:strict_mode] = true
        end
        if yes?('Do you want it to define the role/permission which is not defined when assigning to subject?')
          @options[:auto_define_before] = true
        end
      end

      def setup_migrations
        dest_prefix = 'db/migrate/i_am_i_can_'
        migration_template 'migrations/add_to_subject.erb', "#{dest_prefix}add_role_ids_to_#{name.underscore}.rb"
        migration_template 'migrations/role.erb', "#{dest_prefix}create_#{name.underscore}_roles.rb"
        migration_template 'migrations/role_group.erb', "#{dest_prefix}create_#{name.underscore}_role_groups.rb" unless @options[:without_group]
        migration_template 'migrations/permission.erb', "#{dest_prefix}create_#{name.underscore}_permissions.rb"
      end

      def setup_models
        template 'models/role.rb', "app/models/#{name.underscore}_role.rb"
        template 'models/role_group.rb', "app/models/#{name.underscore}_role_group.rb" unless @options[:without_group]
        template 'models/permission.rb', "app/models/#{name.underscore}_permission.rb"
      end

      def tip
        options = ' ' + @options.to_s[2..-2].gsub('=>', ': ').gsub(', :', ', ') if @options.keys.present?
        puts 'Please add this line to your subject model:'.red
        puts "    act_as_i_am_i_can#{options}".red
      end
    end
  end
end
