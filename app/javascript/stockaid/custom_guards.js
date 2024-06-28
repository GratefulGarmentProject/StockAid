/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$.guards.name("passwordComplexity").message("Please follow the password rules.").using(function(value) {
  if (value === "") { return true; }
  const lengthCheck = $.guards.isValidString(value, {min: 8, max: 72});
  const characterTypeCheck = $.guards.matchesRegex(value, /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/);
  return lengthCheck && characterTypeCheck;
});

$.guards.name("atLeastOneLetter").message("Must contain at lease one letter.").using("regex", /[a-zA-Z]/);

$.guards.name("allOrNone").grouped().message("Please provide all values or none.").using(function(values) {
  let hasBlank = false;
  let hasPresent = false;

  for (var value of Array.from(values)) {
    if ($.guards.isPresent(value)) {
      hasPresent = true;
    } else {
      hasBlank = true;
    }
  }

  return !hasBlank || !hasPresent;
});

$.guards.name("allowedProgram").message(() => `You are not signed up with the right program to order this item. Please contact us at ${$("#contact-us-phone").val()}!`).using(function(value) {
  let item;
  const organizationId = $("#order_organization_id").val();
  if (organizationId === "") { return true; }
  if (value === "") { return true; }

  if (!data.itemByIdCache) {
    data.itemByIdCache = {};

    for (var category of Array.from(data.categories)) {
      for (item of Array.from(category.items)) {
        data.itemByIdCache[item.id] = item;
      }
    }
  }

  const organization = $.grep(data.organizations, o => o.id === parseInt(organizationId))[0];
  item = data.itemByIdCache[value];

  for (var programId of Array.from(organization.program_ids)) {
    if (item.program_ids.indexOf(programId) >= 0) { return true; }
  }

  return false;
});
