expose "formatMoney", (moneyValue) ->
  Number.parseFloat(moneyValue).toFixed(2)

expose "isNullOrUndefined", (value) ->
  value == null || value == undefined
