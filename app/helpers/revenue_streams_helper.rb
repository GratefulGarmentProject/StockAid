module RevenueStreamsHelper
  def revenue_stream_select_options(records)
    if records.nil? || records.is_a?(RevenueStream)
      options_for_select(RevenueStream.active.alphabetical.pluck(:name, :id), records&.id)
    else
      options_for_select(RevenueStream.active.alphabetical.pluck(:name, :id), records.pluck(:id))
    end
  end
end
