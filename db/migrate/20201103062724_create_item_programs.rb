class CreateItemPrograms < ActiveRecord::Migration[5.1]
  def up
    create_table :item_program_ratios do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :item_program_ratio_values do |t|
      t.belongs_to :item_program_ratio, foreign_key: true, null: false
      t.belongs_to :program, foreign_key: true, null: false
      t.decimal :percentage, precision: 5, scale: 2, null: false

      t.timestamps
    end

    resource_closets = Program.find_by_name("Resource Closets")

    only_resource_closets = ItemProgramRatio.create! do |ipr|
      ipr.name = "Only Resource Closets"
      ipr.item_program_ratio_values.build(program: resource_closets, percentage: "100.00")
    end

    add_column :items, :item_program_ratio_id, :integer, null: false, default: only_resource_closets.id
    change_column_default :items, :item_program_ratio_id, nil
    add_foreign_key :items, :item_program_ratios
    add_index :items, [:item_program_ratio_id]
  end

  def down
    remove_column :items, :item_program_ratio_id
    drop_table :item_program_ratio_values
    drop_table :item_program_ratios
  end
end
