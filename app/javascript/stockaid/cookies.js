/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const createCookie = function(name, value, days) {
  if (!days || (days < 1)) { days = 365 * 10; }
  name = encodeURIComponent(name);
  value = encodeURIComponent(`${value}`);
  const expires = new Date();
  expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000));
  return document.cookie = `${name}=${value}; expires=${expires.toGMTString()}; path=/`;
};

const readCookie = function(name, defaultValue) {
  const namePrefix = `${encodeURIComponent(name)}=`;
  const jar = document.cookie.split(";");

  for (var cookie of Array.from(jar)) {
    cookie = cookie.trim();

    if (cookie.indexOf(namePrefix) === 0) {
      return decodeURIComponent(cookie.substring(namePrefix.length, cookie.length));
    }
  }

  return defaultValue;
};

const readCookieInt = function(name, defaultValue) {
  if (defaultValue == null) { defaultValue = 0; }
  const result = readCookie(name, `${defaultValue}`);
  return parseInt(result, 10);
};

$.cookies = {
  create: createCookie,
  read: readCookie,
  readInt: readCookieInt
};
