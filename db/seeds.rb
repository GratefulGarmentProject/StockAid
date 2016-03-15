require "securerandom"

# Empty categories and items
Category.delete_all
OrderDetail.delete_all
Item.delete_all
Order.delete_all
Organization.delete_all
OrganizationUser.delete_all
User.delete_all

# Create organizations
org_stanford = Organization.create(name: "Stanford Hospital", address: "300 Pasteur Drive, Stanford, CA 94305",
                                   phone_number: "(650) 723-4000", email: "info@stanfordhospital.com")
org_kaiser   = Organization.create(name: "Kaiser Permanente Mountain View",
                                   address: "555 Castro St, Mountain View, CA 94041",
                                   phone_number: "(650) 903-3000", email: "info@kaisermountview.com")
org_alameda  = Organization.create(name: "Alameda Hospital", address: "2070 Clinton Ave, Alameda, CA 94501",
                                   phone_number: "(510) 522-3700", email: "info@alamedaahs.org")

# Create site users
User.create(name: "Site Admin", email: "site_admin@fake.com", password: "password",
            password_confirmation: "password", phone_number: "408-555-1234",
            address: "123 Main Street, San Jose, CA, 95123", role: "admin")

User.create(name: "Site User", email: "site_user@fake.com", password: "password",
            password_confirmation: "password", phone_number: "408-555-4321",
            address: "321 Main Street, San Jose, CA, 95321", role: "none")

# Create organization users
alameda_admin = User.create(name: "Alameda Admin", email: "alameda_admin@fake.com", password: "password",
                            password_confirmation: "password", phone_number: "408-555-1234",
                            address: "123 Main Street, San Jose, CA, 95123", role: "none")

alameda_user = User.create(name: "Alameda User", email: "alameda_user@fake.com", password: "password",
                           password_confirmation: "password", phone_number: "408-555-1234",
                           address: "123 Main Street, San Jose, CA, 95123", role: "none")
OrganizationUser.create organization: org_alameda, user: alameda_admin, role: "admin"
OrganizationUser.create organization: org_alameda, user: alameda_user, role: "none"

kaiser_admin = User.create(name: "Kaiser Admin", email: "kaiser_admin@fake.com", password: "password",
                           password_confirmation: "password", phone_number: "408-333-1234",
                           address: "123 Kaiser Street, San Jose, CA, 95123", role: "none")

kaiser_user = User.create(name: "Kaiser User", email: "kaiser_user@fake.com", password: "password",
                          password_confirmation: "password", phone_number: "408-333-1234",
                          address: "123 Kaiser Street, San Jose, CA, 95123", role: "none")
OrganizationUser.create organization: org_kaiser, user: kaiser_admin, role: "admin"
OrganizationUser.create organization: org_kaiser, user: kaiser_user, role: "none"

stanford_admin = User.create(name: "Stanford Admin", email: "stanford_admin@fake.com", password: "password",
                             password_confirmation: "password", phone_number: "408-111-1234",
                             address: "123 Stanford Street, San Jose, CA, 95123", role: "none")

stanford_user = User.create(name: "Stanford User", email: "stanford_user@fake.com", password: "password",
                            password_confirmation: "password", phone_number: "408-111-1234",
                            address: "123 Stanford Street, San Jose, CA, 95123", role: "none")
OrganizationUser.create organization: org_stanford, user: stanford_admin, role: "admin"
OrganizationUser.create organization: org_stanford, user: stanford_user, role: "none"

# Create categories
category_adult_underwear = Category.create(description: "Adult's Underwear")
category_kids_underwear = Category.create(description: "Kids' Underwear")
category_socks = Category.create(description: "Socks")
category_adult_shirts = Category.create(description: "Adults' Shirts")
category_kids_shirts = Category.create(description: "Kids' Shirts")
category_sweaters = Category.create(description: "Sweatshirts/Sweaters")
category_sweatsuits = Category.create(description: "Sweat Suits")
category_pants = Category.create(description: "Pants")
category_shoes = Category.create(description: "Flip-Flops/Slippers")
category_misc = Category.create(description: "Miscellaneous")

# Just a set of numbers to use for an 'In Stock' value
random_numbers = [*0..40]

# Create items
Item.create([
              { description: "Women - Underwear - XS (5)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - S (6)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - M (7)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - L (8)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - 1X (9)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - 2X (10)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - 3X (11)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Underwear - 4X (12)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - S (32)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - M (34)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - L (36)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - 1X (38)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - 2L (40-42)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - 3X (44)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Bra - 4X", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Underwear - XS (28-30)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Underwear- S (32-33)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Underwear - M (34-36)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Underwear - L (38-40)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Underwear - 1X (40-42)", category_id: category_adult_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (2-3)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (4-5)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (6)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (7-8)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (10-12)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (14)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Underwear - (16)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - XXS (2-3T)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - XS (4-5)", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - S", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - M", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - L", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Underwear - XL", category_id: category_kids_underwear.id,
                current_quantity: random_numbers.sample },

              { description: "Women - Socks", category_id: category_socks.id,
                current_quantity: random_numbers.sample },
              { description: "Men - Socks", category_id: category_socks.id,
                current_quantity: random_numbers.sample },
              { description: "\"Cozy\" (winter) Socks", category_id: category_socks.id,
                current_quantity: random_numbers.sample },
              { description: "Girls - Socks", category_id: category_socks.id,
                current_quantity: random_numbers.sample },
              { description: "Boys - Socks", category_id: category_socks.id,
                current_quantity: random_numbers.sample },

              { description: "Women - Shirt - XS", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - S", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - M", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - L", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - 1X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - 2X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - 3X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Women - Shirt - 4X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - S", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - M", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - L", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - 1X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - 2X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - 3X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Shirt - 4X", category_id: category_adult_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Youth - Shirt - XS", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Youth - Shirt - S", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Youth - Shirt - M", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Youth - Shirt - L", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Youth - Shirt - 1X", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - 4T", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - 5T", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - XS", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - S", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - M", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - L", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Shirt - 1X", category_id: category_kids_shirts.id,
                current_quantity: random_numbers.sample },

              { description: "Adult - Sweatshirt/Sweater - XS", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweatshirt/Sweater - S", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweatshirt/Sweater - M", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweatshirt/Sweater - L", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweatshirt/Sweater - 1X", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweatshirt/Sweater - 2X", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - 4T", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - XS", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - S", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - M", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - L", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweatshirt/Sweater - 1X", category_id: category_sweaters.id,
                current_quantity: random_numbers.sample },

              { description: "Adult - Sweat Suit - S", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - M", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - L", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - 1X", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - 2X", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - 3X", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Sweat Suit - 4X", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - XXS (2-3)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - XS (4-5)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - S (6-7)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - M (8-11)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - L (12-13)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Sweat Suit - 1X (14-16)", category_id: category_sweatsuits.id,
                current_quantity: random_numbers.sample },

              { description: "Adult - Pants - XS", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - S", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - M", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - L", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - 1X", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - 2X", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - 3X", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Pants - 4X", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Pants - XS", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Pants - S", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Pants - M", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Pants - L", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Pants - 1X", category_id: category_pants.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Leggings (One Size Fits All)", category_id: category_pants.id,
                current_quantity: random_numbers.sample },

              { description: "Adult - Flip-flops - XXS", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Flip-flops - XS", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Flip-flops - S (6-7)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Flip-flops - M (7-8)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Flip-flops - L (9-10)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Flip-flops - 1X (11-12)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Flip-flops - XS (4-5)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Flip-flops - S (6-7)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Flip-flops - M (7-8)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Flip-flops - L (9-10)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Kids - Flip-flops - 1X (11-12)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Slippers - S (5-6)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Slippers - M (7-8)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Slippers - L (9-10)", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },
              { description: "Adult - Slippers - 1X", category_id: category_shoes.id,
                current_quantity: random_numbers.sample },

              { description: "Blanket", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Hat", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Gloves", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Scarf", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Tote", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Journal", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Book", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Dollar Tree Card", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Tooth Brush", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Toothpaste", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Dental Floss", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Stuffed Animal", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "DVD", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Comb", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "$5.00 Gift Card", category_id: category_misc.id,
                current_quantity: random_numbers.sample },
              { description: "Other", category_id: category_misc.id,
                current_quantity: random_numbers.sample }
            ])

def create_order_for(organization, days_ago)
  order = Order.new(organization_id: organization.id,
                    user: organization.users.sample, order_date: days_ago.days.ago,
                    status: Order.statuses.values.sample)
  random_items.each do |item|
    order.order_details.build(quantity: [*1..item.current_quantity].sample, item_id: item.id)
  end

  if %w(shipped received).include?(order.status)
    ship_date = days_ago - 3
    order.build_shipment(tracking_number: random_tracking_number, shipping_carrier: Shipment.shipping_carriers.values.sample, date: ship_date.days.ago)

    if order.received?
      order.shipment.delivery_date = (ship_date - 3).days.ago
    end
  end

  order.save
end

def random_items
  Item.limit([*1..10].sample).where("current_quantity > 0").order("RANDOM()") # postgres
end

def random_org
  Organization.order("RANDOM()").first
end

def random_tracking_number
  SecureRandom.hex
end

# Create some random orders
orders_to_create = [*10..30].sample

order_days = [*1..59].sample(orders_to_create).sort.reverse
order_days.unshift(60)
order_days.push(0)

order_days.each do |days_ago|
  create_order_for(random_org, days_ago)
end
