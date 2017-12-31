fillFields = (row) ->
  originalNotes = row.find(".donation-original-notes").text()

  notesField = row.find("input[name='donations[notes][]']")
  notesField.val(row.find(".donation-notes-field").data("value") || "")

  dateField = row.find("input[name='donations[date][]']")
  dateValue = row.find(".donation-date-field").data("value")

  unless dateValue
    match = /\b(\d+)\/(\d+)\/(\d+)\b/.exec(originalNotes)

    pad = (x) ->
      if x.length < 2
        "0#{x}"
      else
        x

    if match
      dateValue = "20#{match[3]}-#{pad(match[1])}-#{pad(match[2])}"
    else
      dateValue = row.find(".donation-date").text()

  dateField.val(dateValue)

  depadDecomma = (x) ->
    spacingMatch = /^\s*(.*?)(?:\s|,)*$/.exec(x)

    if spacingMatch
      spacingMatch[1]
    else
      x

  donorSelector = $("#donor-selector")
  name = originalNotes.replace(/\s+(\d+)\/(\d+)\/(\d+)\b/, "")
  address = ""
  email = ""
  notes = ""
  match = /Donation from: (.*?)(?:\s+address: (.*?))?(?:\s+email: (.*?))?(?:\s+notes: (.*?))?$/.exec(name)
  name = depadDecomma(match[1]) if match
  address = depadDecomma(match[2]) if match && match[2]
  email = depadDecomma(match[3]) if match && match[3]
  notes = depadDecomma(match[4]) if match && match[4]

  if donorSelector.val() == ""
    donorSelector.val("new").trigger("change")
    $("#donor-name").val(name)
    $("#donor-address").val(address)
    $("#donor-email").val(email)

  if notesField.val() == ""
    notesField.val(notes)

$(document).on "change", ".migrate-donation-checkbox", ->
  checkbox = $(@)
  row = checkbox.parents("tr:first")

  if checkbox.is(":checked")
    row.find(".donation-notes-field").append("""<input type="text" name="donations[notes][]" class="form-control" />""")
    row.find(".donation-date").hide()
    row.find(".donation-date-field").append("""<input type="text" name="donations[date][]" class="form-control" />""")
    fillFields(row)
  else
    row.find(".donation-notes-field").data("value", row.find(".donation-notes-field input").val()).empty()
    row.find(".donation-date").show()
    row.find(".donation-date-field").data("value", row.find(".donation-date-field input").val()).empty()
