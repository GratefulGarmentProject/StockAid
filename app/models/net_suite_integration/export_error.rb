module NetSuiteIntegration
  class ExportError < StandardError
    def initialize(msg, netsuite_record)
      super(msg)
      @record = netsuite_record
    end

    def failure_details
      @failure_details ||=
        begin
          result = "NetSuite errors: #{@record.errors.size}"

          @record.errors.each_with_index do |x, i|
            result << "\n\n#{i + 1}) #{x.type} - #{x.code}\n  #{x.message}"
          end

          result << "\n\nException details: #{message}\n  #{backtrace.join("\n  ")}"
        end
    end
  end
end
