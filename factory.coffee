



factory = ( param, options ) ->

  # # Matches NodeList, HTMLCollection, vanilla DOM array, jQuery
  # if param.length and param[0] instanceof Node

  # # Matches
  # else if

each = Function.prototype.call.bind( Array.prototype.forEach )

querySelectorAll = ->
  if arguments[0] instanceof Node
    el = arguments[0]
    selector = arguments[1]
  else
    el = document
    selector = arguments[0]
  Array.prototype.slice.call el.querySelectorAll selector

controlTags = ["input", "textarea", "button", "select"]

# we need push.apply somewhere in here. Create a better test case.
findControlElements = ( el, accumulator = [] ) ->
  el = document.body unless el
  if el.tagName.toLowerCase() in controlTags
    accumulator.push( el )
  else
    querySelectorAll( el, controlTags.join ", " ).forEach ( node ) ->
      findControlElements( node, accumulator ) 
  return accumulator

