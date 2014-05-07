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

  # https://gist.github.com/vjt/827679
  camelize : ( str ) ->
    str.replace /(?:^|[-_])(\w)/g, (_, c) ->
      return if c then c.toUpperCase() else ""

  processSelector : ( str ) ->
    utilities.camelize( str ).replace( /\W/g, "" )

  each : ( obj, itr ) ->
    list = if Array.isArray( obj ) then obj.map (e, i) ->  i else Object.keys( obj )
    i = 0
    while i < list.length
      itr( obj[list[i]], list[ i ], obj )
      i += 1

  isEmpty : ( obj ) ->
    return if Array.isArray( obj ) then !!obj.length else !!Object.keys( obj ).length

module.exports = utilities