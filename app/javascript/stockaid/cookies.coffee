createCookie = (name, value, days) ->
  days = 365 * 10 if !days || days < 1
  name = encodeURIComponent(name)
  value = encodeURIComponent("#{value}")
  expires = new Date()
  expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000))
  document.cookie = "#{name}=#{value}; expires=#{expires.toGMTString()}; path=/"

readCookie = (name, defaultValue) ->
  namePrefix = "#{encodeURIComponent(name)}="
  jar = document.cookie.split(";")

  for cookie in jar
    cookie = cookie.trim()

    if cookie.indexOf(namePrefix) == 0
      return decodeURIComponent(cookie.substring(namePrefix.length, cookie.length))

  return defaultValue

readCookieInt = (name, defaultValue = 0) ->
  result = readCookie(name, "#{defaultValue}")
  return parseInt(result, 10)

$.cookies =
  create: createCookie
  read: readCookie
  readInt: readCookieInt
