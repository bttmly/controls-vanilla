BaseControl = require "./base-control.coffee"
SelectControl = require "./select-control.coffee"
ButtonControl = require "./button-control.coffee"
CheckableControl = require "./checkable-control.coffee"
ControlCollection = require "./control-collection.coffee"

utilities = require "./utilities.coffee"
qsa = utilities.qsa
extend = utilities.extend

controlTags = [ "input", "select", "button", "textarea" ]

defaults =


buildControl = ( el ) ->
  switch el.tagName.toLowerCase()
    when "input" or "textarea"
      if el.type is "radio" or el.type is "checkbox"
        return new CheckableControl el
      else
        return new BaseControl el
    when "select"
      return new SelectControl el
    when "button"
      return new ButtonControl el
    else
      throw new TypeError "Non-control element passed!"


Factory = ( element, options = {} ) ->

  settings = extend( {}, defaults, options )

  components = []

  # if first arg is string, we think it's a selector
  if typeof element is "string"
    # check the tag of the first element
    # if it's a control tag, push it into components
    el = document.querySelector( element )
    if el.tagName.toLowerCase() in controlTags
      components.push el
    # if not, find all descendants matching control tags
    # and push them into components
    else 
      Array.prototype.push.apply components, qsa el, controlTags.join( ", " )

  # if first arg has length (and not a string)
  # we think it's array-like ( array, jQuery, NodeList, etc. )
  # so, check each element, and push those matching into components
  else if element.length?
    Array.prototype.forEach.call element, ( el ) ->
      if ( el instanceof ControlCollection ) or ( el instanceof Element and el.tagName.toLowerCase() in controlTags )
        components.push( el )

  # map components into Control instances 
  controls = components.map buildControl

  new ControlCollection( controls, settings )


Factory.BaseControl = BaseControl
Factory.SelectControl = SelectControl
Factory.ButtonControl = ButtonControl
Factory.CheckableControl = CheckableControl
Factory.ControlCollection = ControlCollection

module.exports = Factory
