$.guards.name("passwordComplexity").using (value) ->
  $.guards.matchesRegex(value, /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,72}$/)
