# frozen_string_literal: true
require "open3"
require "stringio"
require "tempfile"

class Backup
  PREFIX = "backup".freeze
  attr_reader :error_message

  # Test if the given filename appears to be a StockAid backup file
  def self.file?(filename)
    filename =~ /\A#{PREFIX}\.\d+\.sql\z/
  end

  def initialize
    return unless block_given?

    begin
      yield(self)
    ensure
      close
    end
  end

  def error?
    backup!
    error_message.present?
  end

  def filename
    @filename ||= "#{PREFIX}.#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.sql"
  end

  def tempfile_path
    backup!
    @tempfile.path
  end

  def stream_response(response)
    backup!
    @response = response
    @tempfile.open

    while str = @tempfile.read(1024) # rubocop:disable Lint/AssignmentInCondition
      response.stream.write(str)
    end
  ensure
    @tempfile.close
  end

  def close
    @response.stream.close if @response
    @tempfile.close! if @tempfile
  end

  private

  def backup!
    return if @backed_up
    backup_to_tempfile
  ensure
    @backed_up = true
  end

  def backup_to_tempfile
    @tempfile = Tempfile.new(filename)
    dump_db
  ensure
    @tempfile.close
  end

  def dump_db
    Open3.popen3(*dump_db_env_and_cmd) do |stdin, stdout, stderr, wait_thread|
      stdin.close
      threads = [wait_thread, stderr_thread(stderr)]
      IO.copy_stream(stdout, @tempfile)
      threads.each(&:join)
      check_for_errors(wait_thread.value)
    end
  end

  def stderr_thread(stderr)
    Thread.new do
      error_output = StringIO.new
      IO.copy_stream(stderr, error_output)
      @error_output = error_output.string
    end
  end

  def check_for_errors(status)
    return if status.success?
    Rails.logger.error "Error while backing up the database
      Command: #{dump_db_cmd.join(' ')}
      Status Code: #{status.exitstatus}
      *** Error Output ***
#{@error_output}
      *** End Error Output ***"
    @error_message = "Error backing up database!"
  end

  ACTIVE_RECORD_PG_DUMP_OPTIONS = {
    host: "--host",
    username: "--username",
    database: "--dbname"
  }.freeze

  def dump_db_env_and_cmd
    dump_db_env + dump_db_cmd
  end

  def dump_db_cmd
    raise "Missing database name!" unless ActiveRecord::Base.connection_config[:database]
    ar_options = ACTIVE_RECORD_PG_DUMP_OPTIONS.select { |option, _| ActiveRecord::Base.connection_config[option] }
    ar_options = ar_options.map { |option, arg| "#{arg}=#{ActiveRecord::Base.connection_config[option]}" }
    %w(pg_dump --clean --no-owner --no-acl --format=p) + ar_options
  end

  def dump_db_env
    if ActiveRecord::Base.connection_config[:password]
      [{ "PGPASSWORD" => ActiveRecord::Base.connection_config[:password] }]
    else
      []
    end
  end
end
