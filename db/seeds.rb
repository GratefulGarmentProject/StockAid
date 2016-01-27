# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

  category_one = Category.create({ description: 'Tops' })
  category_two = Category.create({ description: 'Bottoms' })

  item_one = Item.create({ description: 'Sweatshirt', category_id: category_one.id})
  item_two = Item.create({ description: 'Jeans', category_id: category_two.id})

  Inventory.create({ current_quantity: 10, item_id: item_one.id })
  Inventory.create({ current_quantity: 20, item_id: item_two.id })

