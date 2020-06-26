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

  def complete_confirm_options
    message = ["Are you sure?"]
    message << "There are items with no count sheets!" if deltas.any?(&:no_count_sheets?)

    {
      title: "Completing Reconciliation",
      message: message.join(" ")
    }
  end

  def ready_to_complete?
    reconciliation.count_sheets.all?(&:complete)
  end

  private

  def deltas
    if reconciliation.complete?
      complete_deltas
    else
      incomplete_deltas
    end
  end

  def complete_deltas
    @complete_deltas ||=
      begin
        reconciliation.updated_item_versions.map do |version|
          ReconciliationDeltas::CompletedDelta.new(reconciliation, version)
        end
      end
  end

  def incomplete_deltas
    @incomplete_deltas ||=
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

  # This is common logic used by CompletedDelta and Delta.
  module DeltaConcern
    def changed_amount?
      changed_amount != 0
    end
  end

  class CompletedDelta
    include ReconciliationDeltas::DeltaConcern
    attr_reader :reconciliation, :version

    def initialize(reconciliation, version)
      @reconciliation = reconciliation
      @version = version
    end

    def item
      version.item
    end

    def current_quantity
      version.changeset["current_quantity"].first
    end

    def final_count
      version.changeset["current_quantity"].last
    end

    def changed_amount
      final_count - current_quantity
    end
  end

  class Delta
    include ReconciliationDeltas::DeltaConcern
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

    def reconcile
      return unless changed_amount?
      item.mark_event edit_amount: final_count,
                      edit_method: "new_total",
                      edit_reason: "reconciliation",
                      edit_source: reconciliation.paper_trail_edit_source
      item.save!
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

    def no_count_sheets?
      counts == 0
    end

    def warning_text
      texts = []
      texts << "This item has incomplete count sheets." if includes_incomplete_sheet
      texts << "This item has final counts that aren't yet entered." if includes_missing_final_count
      texts << "This item has no count sheets!" if no_count_sheets?
      texts.join(" ")
    end

    def requested_quantity
      item.requested_quantity
    end

    def current_quantity
      item.current_quantity
    end

    def changed_amount
      @changed_amount ||= final_count - item.current_quantity
    end

    def warning?
      includes_incomplete_sheet || includes_missing_final_count
    end

    def error?
      no_count_sheets?
    end
  end
end
