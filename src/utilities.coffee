extend = ( out ) ->
  out or= {}
  i = 1
  while i < arguments.length
    continue unless arguments[i]
    for own key of arguments[i]
      out[key] = arguments[i][key]
    i++
  out

qsa = ->
  if arguments[0] instanceof Node
    el = arguments[0]
    selector = arguments[1]
  else
    el = document
    selector = arguments[0]
  slice el.querySelectorAll selector

map = Function::call.bind( Array::map )
some = Function::call.bind( Array::some )
slice = Function::call.bind( Array::slice )
filter = Function::call.bind( Array::filter )

find = ( arr, test ) ->
  result = undefined
  some arr, ( value, index, list ) ->
    result = value if test( value, index, list )
  result

each = ( obj, itr ) ->
  list = if Array.isArray( obj ) then obj.map ( e, i ) ->  i else Object.keys( obj )
  i = 0
  while i < list.length
    itr( obj[ list[i] ], list[ i ], obj )
    i += 1
  return

# https://gist.github.com/vjt/827679
camelize = ( str ) ->
  str.replace /(?:^|[-_])(\w)/g, (_, c) ->
    if c then c.toUpperCase() else ""

processSelector = ( str ) ->
  camelize( str ).replace( /\W/g, "" )

mapAllTrue = ( arr, fn ) ->
  arr.map( fn ).every ( item ) -> !!item

# fn should return an array w/ length === 2
mapToObj = ( arr, fn ) ->
  obj = {}
  for i in arr
    keyVal = fn( i )
    if Array.isArray( keyVal) and keyVal.length is 2
      obj[ keyVal[0] ] = keyVal[1]
  obj

isEmpty = ( obj ) ->
  return if Array.isArray( obj ) then !!obj.length else !!Object.keys( obj ).length



module.exports = 
  qsa: qsa  
  map: map
  some: some
  each: each
  find: find
  slice: slice
  filter: filter
  extend: extend
  camelize: camelize
  processSelector: processSelector
  mapAllTrue: mapAllTrue
  mapToObj: mapToObj
  isEmpty: isEmpty




