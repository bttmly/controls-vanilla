BaseControl = require "./base-control.coffee"
SelectControl = require "./select-control.coffee"
ButtonControl = require "./button-control.coffee"
CheckableControl = require "./checkable-control.coffee"
ControlCollection = require "./control-collection.coffee"
validation = require "./validation.coffee"

{ qsa, extend, processSelector } = require "./utilities.coffee"

controlTags = [ "input", "select", "button", "textarea" ]

buildControl = ( el ) ->
  switch el.tagName.toLowerCase()
    when "input" or "textarea"
      if el.type is "radio" or el.type is "checkbox"
        new CheckableControl el
      else
        new BaseControl el
    when "select"
      new SelectControl el
    when "button"
      new ButtonControl el
    else
      throw new TypeError "Non-control element passed!"

Factory = ( element, options = {} ) ->

  components = []

  # if first arg is string, we think it's a selector
  # so, get the matching element and continue
  if typeof element is "string"
    options.id = processSelector( element )
    # check the tag of the first element
    # if it's a control tag, push it into components
    element = document.querySelector( element )
  
  # if we have an Element here, we see if it's a control,
  if element instanceof Element
    if element.tagName.toLowerCase() in controlTags
      components.push element
    # if not, find all descendants matching control tags
    # and push them into components
    else 
      Array.prototype.push.apply components, qsa element, controlTags.join( ", " )

  # if first arg has length (and not a string)
  # we think it's array-like ( array, jQuery, NodeList, etc. )
  # so, check each element, and push those matching into components
  else if element.length?
    Array.prototype.forEach.call element, ( el ) ->
      if ( el instanceof ControlCollection ) or ( el instanceof Element and el.tagName.toLowerCase() in controlTags )
        components.push( el )

  # map components into Control instances 
  controls = components.map ( item ) ->
    if item instanceof Element
      return buildControl( item )
    else
      return item

  new ControlCollection( controls, options )


Factory.addValidation = ( key, val ) ->
  return false if validation[ key ]
  if val instanceof RegExp
    fn = ( str ) ->
      val.match str
  else if val instanceof Function
    fn = val

  validation[ key ] = fn

Factory.BaseControl = BaseControl
Factory.SelectControl = SelectControl
Factory.ButtonControl = ButtonControl
Factory.CheckableControl = CheckableControl
Factory.ControlCollection = ControlCollection

module.exports = Factory
