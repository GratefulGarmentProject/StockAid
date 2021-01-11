$.guards.name("passwordComplexity").message("Please follow the password rules.").using (value) ->
  return true if value == ""
  lengthCheck = $.guards.isValidString(value, min: 8, max: 72)
  characterTypeCheck = $.guards.matchesRegex(value, /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  lengthCheck && characterTypeCheck

$.guards.name("atLeastOneLetter").message("Must contain at lease one letter.").using("regex", /[a-zA-Z]/)

$.guards.name("allOrNone").grouped().message("Please provide all values or none.").using (values) ->
  hasBlank = false
  hasPresent = false

  for value in values
    if $.guards.isPresent(value)
      hasPresent = true
    else
      hasBlank = true

  !hasBlank || !hasPresent

$.guards.name("allowedProgram").message(-> "You are not signed up with the right program to order this item. Please contact us at #{$("#contact-us-phone").val()}!").using (value) ->
  organizationId = $("[name='order[organization_id]']").val()
  return true if organizationId == ""
  return true if value == ""

  unless data.itemByIdCache
    data.itemByIdCache = {}

    for category in data.categories
      for item in category.items
        data.itemByIdCache[item.id] = item

  organization = $.grep(data.organizations, (o) -> o.id == parseInt(organizationId))[0]
  item = data.itemByIdCache[value]

  for programId in organization.program_ids
    return true if item.program_ids.indexOf(programId) >= 0

  return false
