expose "formatMoney", (moneyValue) ->
  Number.parseFloat(moneyValue).toFixed(2)

