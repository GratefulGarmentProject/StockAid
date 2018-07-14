class ReconciliationDeltas
  attr_reader :reconciliation, :items

  def initialize(reconciliation, items = nil)
    @reconciliation = reconciliation
    @items = items || Item.includes(:category).with_requested_quantity.to_a
  end

  def each
    deltas.each do |delta|
      yield delta
    end
  end

  private

  def deltas
    @deltas ||=
      begin
        deltas = items.map { |item| ReconciliationDeltas::Delta.new(reconciliation, item) }
        deltas_by_item_id = deltas.index_by { |delta| delta.item.id }

        reconciliation.count_sheets.each do |count_sheet|
          count_sheet.count_sheet_details.each do |detail|
            delta = deltas_by_item_id[detail.item_id]
            delta.counted(detail)
          end
        end

        deltas
      end
  end

  class Delta
    attr_reader :reconciliation, :item, :includes_incomplete_sheet, :includes_missing_final_count, :counts,
                :final_count, :warning_count_sheet_id

    def initialize(reconciliation, item)
      @reconciliation = reconciliation
      @item = item
      @includes_incomplete_sheet = false
      @includes_missing_final_count = false
      @counts = 0
      @final_count = 0
      @warning_count_sheet_id = nil
    end

    def counted(detail)
      unless detail.count_sheet.complete
        @includes_incomplete_sheet = true
        @warning_count_sheet_id = detail.count_sheet.id
      end

      unless detail.final_count
        @includes_missing_final_count = true
        @warning_count_sheet_id = detail.count_sheet.id
      end

      @final_count += detail.final_count.to_i
      @counts += 1
    end

    def warning_path
      return unless @warning_count_sheet_id
      path = Rails.application.routes.url_helpers
                  .inventory_reconciliation_count_sheet_path(reconciliation, @warning_count_sheet_id)
      %(data-href="#{ERB::Util.html_escape path}").html_safe
    end

    def warning_text
      texts = []
      texts << "This item has incomplete count sheets." if includes_incomplete_sheet
      texts << "This item has final counts that aren't yet entered." if includes_missing_final_count
      texts << "This item has no count sheets!" if counts == 0
      return if texts.empty?
      tooltip = texts.join(" ")
      %(data-toggle="tooltip" data-placement="top" title="#{ERB::Util.html_escape tooltip}").html_safe
    end

    def requested_quantity
      item.requested_quantity
    end

    def current_quantity
      item.current_quantity
    end

    def description_css_class
      return if changed_amount == 0

      if changed_amount > 0
        "text-bold text-success"
      else
        "text-bold text-danger"
      end
    end

    def changed_amount_icon
      return if changed_amount == 0

      if changed_amount > 0
        %(<i class="glyphicon glyphicon-triangle-top"></i>).html_safe
      else
        %(<i class="glyphicon glyphicon-triangle-bottom"></i>).html_safe
      end
    end

    def changed_amount_css_class
      return if changed_amount == 0

      if changed_amount > 0
        "text-success"
      else
        "text-danger"
      end
    end

    def changed_amount
      @changed_amount ||= final_count - item.current_quantity
    end

    def warning?
      includes_incomplete_sheet || includes_missing_final_count
    end

    def error?
      counts == 0
    end

    def row_css_class
      if error?
        "danger"
      elsif warning?
        "warning"
      end
    end
  end
end
