require "open3"

class Backup
  def filename
    @filename ||= "backup.#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.sql"
  end

  def stream(out)
    dump_db do |str|
      out.write(str)
    end
  end

  private

  def dump_db
    Open3.popen2(*dump_db_cmd) do |stdin, stdout, _wait_thread|
      stdin.close

      while str = stdout.read(1024) # rubocop:disable Lint/AssignmentInCondition
        yield(str)
      end
    end
  end

  ACTIVE_RECORD_PG_DUMP_OPTIONS = {
    host: "--host",
    username: "--username",
    database: "--dbname"
  }.freeze

  def dump_db_cmd
    raise "Missing database name!" unless ActiveRecord::Base.connection_config[:database]
    ar_options = ACTIVE_RECORD_PG_DUMP_OPTIONS.select { |option, _| ActiveRecord::Base.connection_config[option] }
    ar_options = ar_options.map { |option, arg| "#{arg}=#{ActiveRecord::Base.connection_config[option]}" }
    dump_db_env + %w(pg_dump --clean --no-owner --no-acl --format=p) + ar_options
  end

  def dump_db_env
    if ActiveRecord::Base.connection_config[:password]
      [{ "PGPASSWORD" => ActiveRecord::Base.connection_config[:password] }]
    else
      []
    end
  end
end
