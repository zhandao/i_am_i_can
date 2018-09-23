# set adapter to use, default is sqlite3
# to use an alternative adapter run => rake spec DB='postgresql'
adapter = ENV['DB'] || 'postgresql'
database_yml = File.expand_path('../../db/database.yml', __FILE__)

ActiveRecord::Migration.verbose = false
# ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations = YAML.load_file(database_yml)
# ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.logger = Logger.new(puts File.join(File.dirname(__FILE__), '../debug.log'))
ActiveRecord::Base.logger.level = ENV['TRAVIS'] ? ::Logger::ERROR : ::Logger::DEBUG

config = ActiveRecord::Base.configurations[adapter]
begin
  ActiveRecord::Base.establish_connection(adapter.to_sym)
  ActiveRecord::Base.connection
rescue
  # :nocov:
  case adapter
  when 'mysql'
    ActiveRecord::Base.establish_connection(config.merge('database' => nil))
    ActiveRecord::Base.connection.create_database(config['database'], {charset: 'utf8', collation: 'utf8_unicode_ci'})
  when 'postgresql'
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => 'utf8'))
  end

  ActiveRecord::Base.establish_connection(config)
  # :nocov:
end

require File.dirname(__FILE__) + '/../db/schema.rb'
