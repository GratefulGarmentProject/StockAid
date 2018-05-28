class BackfilVersionDataForPaperTrail < ActiveRecord::Migration
  def change
    item_count = Item.count

    percentages = (1...9).map { |n| (item_count * n/10.0).to_i }

    puts "> Going to ensure item initial fill is done for #{item_count} Items."

    Item.unscoped.includes(:versions).each_with_index.map do |item,i|
      first_version = item.versions.order(:created_at).first
      first_version.edit_reason = "initial_fill" if first_version.edit_reason.nil?
      first_version.save!

      puts ">> #{((i.to_f / item_count) * 100).round}\% done" if percentages.include?(i)
    end

    puts "> Completed."
  end
end
