$.guards.name("passwordComplexity").message("Please follow the password rules.").using (value) ->
  return true if value == ""
  lengthCheck = $.guards.isValidString(value, min: 8, max: 72)
  characterTypeCheck = $.guards.matchesRegex(value, /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  lengthCheck && characterTypeCheck

$.guards.name("atLeastOneLetter").message("Must contain at lease one letter.").using("regex", /[a-zA-Z]/)
