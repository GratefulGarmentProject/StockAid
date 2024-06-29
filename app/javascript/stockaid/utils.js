/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
expose("formatMoney", moneyValue => Number.parseFloat(moneyValue).toFixed(2));

expose("isNullOrUndefined", value => (value === null) || (value === undefined));
