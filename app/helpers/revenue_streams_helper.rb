module RevenueStreamsHelper
  def revenue_stream_select_options(records)
    options_for_select(RevenueStream.active.alphabetical.pluck(:name, :id), records.pluck(:id))
  end
end
