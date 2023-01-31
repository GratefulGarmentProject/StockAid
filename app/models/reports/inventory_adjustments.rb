module Reports
  class InventoryAdjustments
    FILTERABLE_REASONS = %w[reconciliation spoilage transfer transfer_internal transfer_external purchase donation
                            adjustment].freeze

    def self.reason_label(reason)
      case reason
      when "adjustment"
        "Other"
      when "transfer"
        "Legacy transfer"
      when "transfer_internal"
        "Internal transfer"
      when "transfer_external"
        "External transfer"
      when "purchase"
        "Legacy purchase"
      else
        reason.humanize.capitalize
      end
    end

    def initialize(params, _session)
      @params = params
    end

    def start_date
      @start_date ||= Time.strptime(@params[:start_date], "%m/%d/%Y").beginning_of_day
    end

    def end_date
      @end_date ||= Time.strptime(@params[:end_date], "%m/%d/%Y").end_of_day
    end

    def each
      Item.unscoped do
        filtered_scope.each do |version|
          yield Reports::InventoryAdjustments::Row.new(version)
        end
      end
    end

    def filtered_reasons
      (@params[:reasons].presence || Reports::InventoryAdjustments::FILTERABLE_REASONS).dup
    end

    def filtered_scope
      Item.paper_trail.version_class
          .includes(:item)
          .where(edit_reason: filtered_reasons)
          .where(created_at: (start_date..end_date))
    end

    class Row
      attr_reader :version

      delegate :item, to: :version
      delegate :description, to: :item, prefix: true

      def initialize(version)
        @version = version
      end

      def date
        version.created_at
      end

      def edit_description
        version.edit_source
      end

      def reason
        Reports::InventoryAdjustments.reason_label(version.edit_reason)
      end

      def value
        @value ||= version.reify.value
      end

      def amount
        @amount ||=
          case version.edit_method
          when "add"
            version.edit_amount
          when "subtract"
            -version.edit_amount
          else
            changed_amount
          end
      end

      def total_value
        amount * value
      end

      private

      def final_count
        version.changeset["current_quantity"].last
      end

      def current_quantity
        version.changeset["current_quantity"].first
      end

      def changed_amount
        return (final_count - current_quantity) unless final_count.nil? || current_quantity.nil?
        raise "Could not determine changed amount for version: #{version.id}"
      end
    end
  end
end
