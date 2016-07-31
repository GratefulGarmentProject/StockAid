require "spreadsheet"
require "stringio"
require "tempfile"

class Export
  attr_reader :error_message

  def initialize
    return unless block_given?

    begin
      yield(self)
    ensure
      close
    end
  end

  def stream_response(response)
    @response = response

    create_spreadsheet
    tempfile.open

    while str = tempfile.read(1024) # rubocop:disable Lint/AssignmentInCondition
      response.stream.write(str)
    end
  ensure
    tempfile.close
  end

  def close
    @response.stream.close if @response
    @tempfile.close! if @tempfile
  end

  def filename
    @filename ||= "master_inventory_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xls"
  end

  def tempfile
    @tempfile ||= Tempfile.new(filename)
  end

  def create_spreadsheet
    return if @created
    SpreadsheetExporter.master_inventory.write(tempfile)
  rescue => e
    Rails.logger.error "Spreadsheet wasn't able to be created and written to file
      *** Error Output ***
#{e} (#{e.class})
  #{e.backtrace.join("\n  ")}
      *** End Error Output ***"
    @error_message = "Error creating spreadsheet!"
  ensure
    @created = true
  end
end
