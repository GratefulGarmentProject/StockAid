# This function should be used instead of:
#   window.something = -> ...
# which can sometimes look like the "window." is an accident. Instead, use:
#   expose "something", -> ...
expose = (name, fn) ->
  window[name] = fn

expose "expose", expose
