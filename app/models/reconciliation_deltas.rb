class ReconciliationDeltas
  attr_reader :reconciliation, :items

  def initialize(reconciliation, items = nil)
    @reconciliation = reconciliation
    item_scope =
      if reconciliation.complete?
        Item.unscoped
      else
        Item
      end
    @items = items || item_scope.includes(:category).with_requested_quantity.to_a
  end

  def each(&block)
    deltas.each(&block)
  end

  def complete_confirm_options
    message = ["Are you sure?"]
    message << "There are items with no count sheets!" if deltas.any?(&:no_count_sheets?)
    message << "There are items with uncounted bins!" if deltas.any?(&:has_uncounted_bins?)

    {
      title: "Completing Reconciliation",
      message: message.join(" ")
    }
  end

  def ready_to_complete?
    reconciliation.count_sheets.all?(&:complete)
  end

  def total_value_changed
    deltas.map(&:total_value_changed).sum
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
      reconciliation.updated_item_versions.map do |version|
        ReconciliationDeltas::CompletedDelta.new(reconciliation, version)
      end
  end

  def incomplete_deltas # rubocop:disable Metrics/AbcSize
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

        reconciliation.ignored_bins.includes(:items).each do |bin|
          bin.items.each do |item|
            delta = deltas_by_item_id[item.id]
            delta.uncounted_bin(bin)
          end
        end

        deltas.delete_if(&:no_count_sheets?)
        deltas
      end
  end

  # This is common logic used by CompletedDelta and Delta.
  module DeltaConcern
    def description_css_class
      return unless changed_amount?

      if changed_amount > 0
        "text-bold text-success"
      else
        "text-bold text-danger"
      end
    end

    def changed_amount?
      changed_amount != 0
    end

    def changed_amount_css_class
      return unless changed_amount?

      if changed_amount > 0
        "text-success"
      else
        "text-danger"
      end
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

    def total_value_changed
      @total_value_changed ||= version.reify.value * changed_amount
    end
  end

  class Delta
    include ReconciliationDeltas::DeltaConcern
    attr_reader :reconciliation, :item, :includes_incomplete_sheet, :includes_missing_final_count, :counts,
                :warning_count_sheet_id

    def initialize(reconciliation, item)
      @reconciliation = reconciliation
      @item = item
      @includes_incomplete_sheet = false
      @includes_missing_final_count = false
      @counts = 0
      @misfits_counts = 0
      @uncounted_bins = 0
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
      @misfits_counts += 1 if detail.count_sheet.misfits?
      @counts += 1
    end

    def uncounted_bin(_bin)
      @uncounted_bins += 1
    end

    def no_count_sheets?
      counts == 0
    end

    def warning_text
      texts = []
      texts << "This item has incomplete count sheets." if includes_incomplete_sheet
      texts << "This item has final counts that aren't yet entered." if includes_missing_final_count
      texts << "This item has bins that are ignored from this reconciliation." if has_uncounted_bins?
      texts << "This item has no count sheets!" if no_count_sheets?
      texts.join(" ")
    end

    def requested_quantity
      item.requested_quantity
    end

    def current_quantity
      item.current_quantity
    end

    def final_count
      if only_misfits?
        current_quantity + @final_count
      else
        @final_count
      end
    end

    def changed_amount
      @changed_amount ||= final_count - item.current_quantity
    end

    def total_value_changed
      @total_value_changed ||= item.value * changed_amount
    end

    def only_misfits?
      @counts == @misfits_counts
    end

    def has_uncounted_bins? # rubocop:disable Naming/PredicateName
      # Misfit only deltas don't count as uncounted because they purely get
      # added to the existing stock of that item
      return false if only_misfits?
      @uncounted_bins > 0
    end

    def warning?
      includes_incomplete_sheet || includes_missing_final_count || has_uncounted_bins?
    end

    def error?
      no_count_sheets?
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
