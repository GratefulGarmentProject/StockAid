/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// This function should be used instead of:
//   window.something = -> ...
// which can sometimes look like the "window." is an accident. Instead, use:
//   expose "something", -> ...
const expose = (name, fn) => window[name] = fn;

expose("expose", expose);
