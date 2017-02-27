looksLikeMoney = (value) -> /^(-|\+)?[\d,]+(\.?\d{2})?$/.test(value)
hasInvalidCommas = (value) -> value.indexOf(",") >= 0 && !/^(-|\+)?\$?[1-9]\d{0,2}(,\d{3})+(\.\d{2})?$/.test(value)

moneyNoDollar = (value, options) ->
  value = $.trim(value)
  return true if value == ""
  return false unless looksLikeMoney(value)
  return false if hasInvalidCommas(value)
  $.guards.isInRange parseFloat(value.replace(/,/g, "")), options

guard = $.guards.name("moneynodollar").using($.guards.aggregate($.guards.isAllValid, moneyNoDollar))

guard.moneyNoDollarErrorElement = (message) ->
  $("""<#{@getTag()} class="#{@getMessageClass()}"/>""").html(message)

guard.moneyNoDollarMessageFn = (elements) ->
  value = $(elements).val()
  return @moneyNoDollarErrorElement("Please don't include the dollar sign ($).") if value.indexOf("$") >= 0
  return @moneyNoDollarErrorElement("Please round your cents to 2 digits.") if /\.\d{3,}$/.test(value)
  return @moneyNoDollarErrorElement("Did you misstype your cents?") if /\.\d?$/.test(value)
  return @moneyNoDollarErrorElement("Please enter a valid amount (like <strong>10.50</strong>).") unless looksLikeMoney(value)
  return @moneyNoDollarErrorElement("Please only use commas every 3 digits.") if hasInvalidCommas(value)

  minMaxOptions =
    minAndMax: "Please enter an amount from $\#{0} to $\#{1}."
    min: "Please enter an amount no less than $\#{0}."
    max: "Please enter an amount no greater than $\#{0}."
    invalid: "Please enter a dollar amount."

  messageFn = $.guards.minMaxMessage minMaxOptions, (x) -> x.toFixed(2)
  message = messageFn.apply @, @getGuardArguments(elements)
  @moneyNoDollarErrorElement(message)

guard.messageFn (elements) -> guard.moneyNoDollarMessageFn(elements)

$.eachCategory = (callback) ->
  callback(category) for category in data.categories

$.eachInventoryItem = (category, callback) ->
  if arguments.length == 1
    # A call without a category iterates through all items in all categories
    callback = category
    $.eachCategory((c) -> callback(item, c) for item in c.items)
  else
    callback(item, category) for item in category.items

$(document).on "page:change", ->
  $("[data-toggle='tooltip']").tooltip()
