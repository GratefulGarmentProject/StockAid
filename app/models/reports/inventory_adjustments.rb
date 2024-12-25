module Reports
  class InventoryAdjustments
    include CsvExport
    FILTERABLE_REASONS = %w[reconciliation spoilage transfer transfer_internal transfer_external purchase
                            donation donation_adjustment
                            adjustment order_adjustment
                            purchase_shipment_received purchase_shipment_deleted].freeze
    FIELDS = %w[Item Reason Description Amount Value TotalValue Date].freeze

    def self.reason_label(reason) # rubocop:disable Metrics/MethodLength
      case reason
      when "donation_adjustment"
        "Deleted donation"
      when "adjustment"
        "Other"
      when "order_adjustment"
        "Order"
      when "transfer"
        "Legacy transfer"
      when "transfer_internal"
        "Internal transfer"
      when "transfer_external"
        "External transfer"
      when "purchase"
        "Legacy purchase"
      when "purchase_shipment_received"
        "Purchase"
      when "purchase_shipment_deleted"
        "Deleted purchase"
      else
        reason.humanize.capitalize
      end
    end

    def self.short_reason_label(reason) # rubocop:disable Metrics/MethodLength
      case reason
      when "reconciliation"
        "Reconcile"
      when "spoilage"
        "Spoil"
      when "transfer"
        "LgcyXfer"
      when "transfer_internal"
        "IntXfer"
      when "transfer_external"
        "ExtXfer"
      when "purchase"
        "LgcyPurchase"
      when "donation"
        "Donation"
      when "donation_adjustment"
        "DeletedDonation"
      when "adjustment"
        "Other"
      when "order_adjustment"
        "Order"
      when "purchase_shipment_received"
        "Purchase"
      when "purchase_shipment_deleted"
        "DeletedPurchase"
      else
        reason.humanize.capitalize
      end
    end

    def initialize(params, _session)
      @params = params
    end

    def csv_filename
      style_part = selected_style.capitalize

      reasons =
        if all_reasons?
          "AllReasons"
        else
          filtered_reasons.map { |x| self.class.short_reason_label(x) }.join("_")
        end

      date_part = "#{start_date.strftime('%m-%d-%Y')}_to_#{end_date.strftime('%m-%d-%Y')}"
      "inventory-adjustments_#{style_part}_#{reasons}_#{date_part}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
    end

    def csv_export_row(row)
      [
        row.item_description,
        row.reason,
        row.edit_description,
        row.amount,
        row.value,
        row.total_value,
        row.date&.strftime("%m/%d/%Y")
      ]
    end

    def selected_style
      @params[:style].presence || "full"
    end

    def start_date
      @start_date ||= Time.strptime(@params[:start_date], "%m/%d/%Y").beginning_of_day
    end

    def end_date
      @end_date ||= Time.strptime(@params[:end_date], "%m/%d/%Y").end_of_day
    end

    def condensed?
      selected_style == "condensed"
    end

    def each(&)
      if condensed?
        each_condensed_row(&)
      else
        each_row(&)
      end
    end

    def all_reasons?
      return true if @params[:reasons].blank?

      chosen_reasons = Set.new(@params[:reasons])
      Reports::InventoryAdjustments::FILTERABLE_REASONS.all? { |x| chosen_reasons.include?(x) }
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

    def each_condensed_row
      condensed_data = {}

      each_row do |row|
        condensed_data[row.condensed_key] ||= Reports::InventoryAdjustments::CondensedRow.new
        condensed_data[row.condensed_key] << row
      end

      condensed_data.values.each do |condensed_row|
        yield condensed_row
      end
    end

    def each_row
      Item.unscoped do
        filtered_scope.each do |version|
          yield Reports::InventoryAdjustments::Row.new(version)
        end
      end
    end

    class CondensedRow
      def initialize
        @rows = []
      end

      def <<(row)
        @rows << row
      end

      def edit_description
        nil
      end

      def item_description
        @rows.first.item_description
      end

      def reason
        @rows.first.reason
      end

      def amount
        @rows.sum(&:amount)
      end

      def value
        @rows.sum(&:value)
      end

      def total_value
        @rows.sum(&:total_value)
      end

      def date
        nil
      end
    end

    class Row
      attr_reader :version

      delegate :item, to: :version
      delegate :description, to: :item, prefix: true

      def initialize(version)
        @version = version
      end

      def condensed_key
        "#{item.id}:#{reason}"
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
