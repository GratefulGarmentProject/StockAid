require "securerandom"

# Reset Order model for people who oneline db:migrate and db:seed
Donor.reset_column_information
Order.reset_column_information
Purchase.reset_column_information

# Empty all records
# Order must be maintained to be successful
DonorAddress.delete_all
DonationDetail.delete_all
Donation.delete_all
Donor.delete_all

PurchaseShipment.delete_all
PurchaseDetail.delete_all
Purchase.delete_all
VendorAddress.delete_all
Vendor.delete_all

OrderDetail.delete_all
Order.delete_all

OrganizationAddress.delete_all
OrganizationUser.delete_all
UserInvitation.delete_all
User.delete_all
Address.delete_all
OrganizationProgram.delete_all
Organization.delete_all

Item.delete_all
Category.delete_all

ItemProgramRatioValue.delete_all
ItemProgramRatio.delete_all
Program.delete_all

# Create Programs
resource_closets = Program.find_or_create_by(name: "Resource Closets", initialized_name: "RC", external_id: 6, external_class_id: 1)
Program.find_or_create_by(name: "Beyond the Closet", initialized_name: "BtC", external_id: 12, external_class_id: 2)
Program.find_or_create_by(name: "Pack-It-Forward", initialized_name: "PIF", external_id: 5, external_class_id: 3)
Program.find_or_create_by(name: "Operation Esteem", initialized_name: "OE", external_id: 9, external_class_id: 5)
Program.find_or_create_by(name: "Dress for Dignity", initialized_name: "DfD", external_id: 2, external_class_id: 4)
Program.find_or_create_by(name: "Beautification Projects", initialized_name: "BP", external_id: 1, external_class_id: 6)

# Create organizations
org_stanford = Organization.create(name: "Stanford Hospital", phone_number: "(650) 723-4000",
                                   email: "info@stanfordhospital.com", county: "Stanford County",
                                   external_id: 1, external_type: "Organization",
                                   addresses: [
                                     Address.create(address: "300 Pasteur Drive, Stanford, CA 94305")
                                   ])
org_kaiser   = Organization.create(name: "Kaiser Permanente Mountain View", phone_number: "(650) 903-3000",
                                   email: "info@kaisermountview.com", county: "Santa Clara County",
                                   external_id: 2, external_type: "Organization",
                                   addresses: [
                                     Address.create(address: "555 Castro St, Mountain View, CA 94041")
                                   ])
org_alameda  = Organization.create(name: "Alameda Hospital", phone_number: "(510) 522-3700",
                                   email: "info@alamedaahs.org", county: "Alameda County",
                                   external_id: 3, external_type: "Organization",
                                   addresses: [
                                     Address.create(address: "2070 Clinton Ave, Alameda, CA 94501")
                                   ])

org_stanford.programs = Program.all.sample(4)
org_kaiser.programs = Program.all.sample(2)
org_alameda.programs = Program.all.sample(3)

org_stanford.save!
org_kaiser.save!
org_alameda.save!

user_password =
  if Rails.env.review?
    ENV.fetch("STOCKAID_SEED_PASSWORD")
  else
    "Password1"
  end

# Create site users
@site_admin = User.create(name: "Site Admin", email: "site_admin@fake.com", password: user_password,
                          password_confirmation: user_password, primary_number: "408-555-1234",
                          secondary_number: "919-448-1606", role: "admin")

User.create(name: "Site User", email: "site_user@fake.com", password: user_password,
            password_confirmation: user_password, primary_number: "408-555-4321",
            secondary_number: "919-448-1606", role: "none")

invite_stanford = UserInvitation.create(organization_id: org_stanford.id, email: "fake_invite@stanford.com",
                                        invited_by_id: @site_admin.id, expires_at: Time.zone.now + 4.days,
                                        name: "Fake Stanford", role: "none")

invite_kaiser = UserInvitation.create(organization_id: org_kaiser.id, email: "fake_invite@kaiser.com",
                                      invited_by_id: @site_admin.id, expires_at: Time.zone.now + 12.hours,
                                      name: "Fake Kaiser", role: "none")

invite_alameda = UserInvitation.create(organization_id: org_alameda.id, email: "fake_invite@alameda.com",
                                       invited_by_id: @site_admin.id, expires_at: Time.zone.now - 12.hours,
                                       name: "Fake Alameda", role: "none")

invite_stanford.expires_at = Time.zone.now + 4.days
invite_stanford.save!
invite_kaiser.expires_at = Time.zone.now + 12.hours
invite_kaiser.save!
invite_alameda.expires_at = Time.zone.now - 12.hours
invite_alameda.save!

# Create organization users
alameda_admin = User.create(name: "Alameda Admin", email: "alameda_admin@fake.com", password: user_password,
                            password_confirmation: user_password, primary_number: "408-555-1234",
                            secondary_number: "919-448-1606", role: "none")

alameda_user = User.create(name: "Alameda User", email: "alameda_user@fake.com", password: user_password,
                           password_confirmation: user_password, primary_number: "408-555-1234",
                           secondary_number: "919-448-1606", role: "none")

OrganizationUser.create organization: org_alameda, user: alameda_admin, role: "admin"
OrganizationUser.create organization: org_alameda, user: alameda_user, role: "none"

kaiser_admin = User.create(name: "Kaiser Admin", email: "kaiser_admin@fake.com", password: user_password,
                           password_confirmation: user_password, primary_number: "408-333-1234",
                           secondary_number: "919-448-1606", role: "none")

kaiser_user = User.create(name: "Kaiser User", email: "kaiser_user@fake.com", password: user_password,
                          password_confirmation: user_password, primary_number: "408-333-1234",
                          secondary_number: "919-448-1606", role: "none")

OrganizationUser.create organization: org_kaiser, user: kaiser_admin, role: "admin"
OrganizationUser.create organization: org_kaiser, user: kaiser_user, role: "none"

stanford_admin = User.create(name: "Stanford Admin", email: "stanford_admin@fake.com", password: user_password,
                             password_confirmation: user_password, primary_number: "408-111-1234",
                             secondary_number: "919-448-1606", role: "none")

stanford_user = User.create(name: "Stanford User", email: "stanford_user@fake.com", password: user_password,
                            password_confirmation: user_password, primary_number: "408-111-1234",
                            secondary_number: "919-448-1606", role: "none")

OrganizationUser.create organization: org_stanford, user: stanford_admin, role: "admin"
OrganizationUser.create organization: org_stanford, user: stanford_user, role: "none"

# Create Donors
Donor.create(name: "Jean-Luc Picard", primary_number: "(510) 555-1234",
             email: "jlpicard@ncc-1701-c.com", external_id: 4,
             external_type: "Individual", addresses: [
               Address.create(address: "123 Happy Giver Blvd, Pleasenton, CA, 94566")
             ])

Donor.create(name: "William T. Riker", primary_number: "(510) 555-2345",
             email: "wriker@ncc-1701-c.com", external_id: 5,
             external_type: "Individual", addresses: [
               Address.create(address: "234 Happy Giver Blvd, Pleasenton, CA, 94566")
             ])

Donor.create(name: "Deanna Troi", primary_number: "(510) 555-3456",
             email: "dtroi@ncc-1701-c.com", external_id: 6,
             external_type: "Individual", addresses: [
               Address.create(address: "345 Happy Giver Blvd, Pleasenton, CA, 94566")
             ])

# Create Vendors
Vendor.create(name: "Q's Mart", phone_number: "(510) 555-4321",
              email: "q@qs-mart.com.com", website: "www.qs-mart.com",
              contact_name: "Q", addresses: [
                Address.create(address: "321 Buy More Place, San Ramon, CA, 94582")
              ])

Vendor.create(name: "Guinan's Goods", phone_number: "(510) 555-5432",
              email: "guinan@guinansgoods.com", website: "https://www.guinansgoods.com",
              contact_name: "Guinan", addresses: [
                Address.create(address: "432 10th Ford, San Ramon, CA, 94582")
              ])

Vendor.create(name: "Diplomatico", phone_number: "(510) 555-6543",
              email: "ltroi@diplimatico.com", website: "diplimatico.com",
              contact_name: "Lwaxana Troi", addresses: [
                Address.create(address: "345 Betazed Blvd, San Ramon, CA, 94582")
              ])

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

# Random value generator
def random_value
  ((rand * (5 - 0.01)) + 0.01).round(2)
end

# Create item program ratios
default_ratio = ItemProgramRatio.find_or_create_by(name: "Only Resource Closets") do |ipr|
  ipr.item_program_ratio_values.build(program: resource_closets, percentage: "100.00")
end

# Create items
Item.create(
  [
    { description: "Women - Underwear - XS (5)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - S (6)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - M (7)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - L (8)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - 1X (9)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - 2X (10)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - 3X (11)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Underwear - 4X (12)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - S (32)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - M (34)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - L (36)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - 1X (38)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - 2L (40-42)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - 3X (44)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Bra - 4X", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Underwear - XS (28-30)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Underwear- S (32-33)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Underwear - M (34-36)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Underwear - L (38-40)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Underwear - 1X (40-42)", category_id: category_adult_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (2-3)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (4-5)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (6)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (7-8)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (10-12)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (14)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Underwear - (16)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - XXS (2-3T)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - XS (4-5)", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - S", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - M", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - L", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Underwear - XL", category_id: category_kids_underwear.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Women - Socks", category_id: category_socks.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Men - Socks", category_id: category_socks.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "\"Cozy\" (winter) Socks", category_id: category_socks.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Girls - Socks", category_id: category_socks.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Boys - Socks", category_id: category_socks.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Women - Shirt - XS", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - S", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - M", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - L", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - 1X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - 2X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - 3X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Women - Shirt - 4X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - S", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - M", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - L", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - 1X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - 2X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - 3X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Shirt - 4X", category_id: category_adult_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Youth - Shirt - XS", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Youth - Shirt - S", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Youth - Shirt - M", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Youth - Shirt - L", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Youth - Shirt - 1X", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - 4T", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - 5T", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - XS", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - S", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - M", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - L", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Shirt - 1X", category_id: category_kids_shirts.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Adult - Sweatshirt/Sweater - XS", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweatshirt/Sweater - S", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweatshirt/Sweater - M", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweatshirt/Sweater - L", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweatshirt/Sweater - 1X", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweatshirt/Sweater - 2X", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - 4T", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - XS", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - S", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - M", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - L", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweatshirt/Sweater - 1X", category_id: category_sweaters.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Adult - Sweat Suit - S", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - M", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - L", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - 1X", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - 2X", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - 3X", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Sweat Suit - 4X", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - XXS (2-3)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - XS (4-5)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - S (6-7)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - M (8-11)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - L (12-13)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Sweat Suit - 1X (14-16)", category_id: category_sweatsuits.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Adult - Pants - XS", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - S", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - M", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - L", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - 1X", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - 2X", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - 3X", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Pants - 4X", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Pants - XS", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Pants - S", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Pants - M", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Pants - L", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Pants - 1X", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Leggings (One Size Fits All)", category_id: category_pants.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Adult - Flip-flops - XXS", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Flip-flops - XS", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Flip-flops - S (6-7)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Flip-flops - M (7-8)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Flip-flops - L (9-10)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Flip-flops - 1X (11-12)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Flip-flops - XS (4-5)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Flip-flops - S (6-7)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Flip-flops - M (7-8)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Flip-flops - L (9-10)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Kids - Flip-flops - 1X (11-12)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Slippers - S (5-6)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Slippers - M (7-8)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Slippers - L (9-10)", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Adult - Slippers - 1X", category_id: category_shoes.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },

    { description: "Blanket", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Hat", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Gloves", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Scarf", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Tote", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Journal", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Book", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Dollar Tree Card", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Tooth Brush", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Toothpaste", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Dental Floss", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Stuffed Animal", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "DVD", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Comb", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "$5.00 Gift Card", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id },
    { description: "Other", category_id: category_misc.id,
      current_quantity: random_numbers.sample, value: random_value, item_program_ratio_id: default_ratio.id }
  ]
)

def create_order_for(organization, days_ago) # rubocop:disable Metrics/AbcSize
  order = Order.new(organization_id: organization.id,
                    user: organization.users.sample,
                    order_date: days_ago.days.ago,
                    ship_to_name: organization.name,
                    ship_to_address: organization.primary_address,
                    status: Order.statuses.values.sample)

  add_items(order, random_items)
  add_shipping_info(order, days_ago) if %w[shipped received closed].include?(order.status)

  order.save
  order.created_at = days_ago.days.ago
  order.order_details.each { |od| od.created_at = days_ago.days.ago }
  order.save
end

def add_items(order, items)
  items.each do |item|
    quantity = [*1..item.current_quantity].sample
    requested_quantity = quantity + [*0..3].sample
    order.order_details.build(item_id: item.id,
                              value: item.value,
                              quantity: quantity,
                              requested_quantity: requested_quantity)
  end
end

def add_shipping_info(order, order_date)
  ship_date = order_date - 3
  delivery_date = ship_date - 2
  tracking_detail = TrackingDetail.new(
    order_id: order.id,
    tracking_number: random_tracking_number,
    shipping_carrier: TrackingDetail.shipping_carriers.values.sample,
    date: ship_date.days.ago
  )

  tracking_detail.delivery_date = delivery_date.days.ago if order.received?
  order.tracking_details << tracking_detail
end

def random_items
  Item.limit([*1..10].sample).where("current_quantity > 0").order(Arel.sql("RANDOM()")) # postgres
end

def random_org
  Organization.order(Arel.sql("RANDOM()")).first
end

def random_tracking_number
  SecureRandom.hex
end

# Create some random orders
order_days = []

[*100..150].sample.times do
  order_days << [*0..200].sample
end

order_days.each do |days_ago|
  create_order_for(random_org, days_ago)
end

#############
# PURCHASES #
#############
def create_purchase_from(vendor, days_ago, user)
  purchase = Purchase.new(
    user: user,
    vendor: vendor,
    vendor_po_number: Time.current.to_i,
    status: %i[purchased shipped received closed].sample,
    purchase_date: days_ago.days.ago,
    shipping_cost: [*100..1000].sample / 100.0,
    tax: [*100..1000].sample / 100.0
  )
  num_details = [*1..7].sample
  add_purchase_details(purchase, num_details)
end

def add_purchase_details(purchase, num_details)
  items = Item.order(Arel.sql("RANDOM()")).limit(num_details)

  items.each do |item|
    pd = purchase.purchase_details.build(
      purchase: purchase,
      item: item,
      quantity: [*10..50].sample,
      cost: [*1..1000].sample / 100.0
    )
    pd.save!

    add_purchase_shipments(pd, [*0..3].sample) if %i[received closed].include?(purchase.status.to_sym)
  end

  purchase.save!
end

def add_purchase_shipments(purchase_detail, num_shipments)
  quantity_remaining = purchase_detail.quantity

  0.upto(num_shipments) do |i|
    quantity_received = [*1..quantity_remaining].sample
    quantity_remaining -= quantity_received
    purchase_detail.purchase_shipments.create(
      quantity_received: quantity_received,
      received_date: purchase_detail.purchase.purchase_date + i.days
    )
    break if quantity_remaining < 1
  end
end

# Create some random purchases
vendor_ids = Vendor.pluck(:id)

[*10..50].sample.times do
  rand_vendor = Vendor.find(vendor_ids.sample)
  create_purchase_from(rand_vendor, [*10..20].sample, @site_admin)
end

def add_donations
  donor_ids = Donor.pluck(:id)
  rand_donor = Donor.find(donor_ids.sample)
  donation_date = [*5..20].sample.days.ago

  donation = Donation.new(
    user: @site_admin,
    donor: rand_donor,
    donation_date: donation_date
  )

  num_details = [*1..7].sample
  items = Item.order(Arel.sql("RANDOM()")).limit(num_details)

  items.each do |item|
    dd = donation.donation_details.build(
      item: item,
      quantity: [*2..20].sample,
      value: item.value
    )
    dd.save!
  end

  donation.save!
end

# Create some random donations
add_donations
