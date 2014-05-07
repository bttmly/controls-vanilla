utilities = 
  extend : ( out ) ->
    out or= {}
    i = 1
    while i < arguments.length
      continue  unless arguments[i]
      for own key of arguments[i]
        out[key] = arguments[i][key]
      i++
    out

  qsa : ->
    if arguments[0] instanceof Node
      el = arguments[0]
      selector = arguments[1]
    else
      el = document
      selector = arguments[0]
    utilities.slice el.querySelectorAll selector

  slice : ( arr, args... ) ->
    Array.prototype.slice.apply arr, args

  filter : ( arr, cb ) ->
    Array.prototype.filter.call( arr, cb )

module.exports = utilities