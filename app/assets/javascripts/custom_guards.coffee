$.guards.name("passwordComplexity").message("Please follow the password rules.").using (value) ->
  lengthCheck = $.guards.isValidString(value, min: 8, max: 72)
  characterTypeCheck = $.guards.matchesRegex(value, /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  lengthCheck && characterTypeCheck
