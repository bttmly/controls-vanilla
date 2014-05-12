{ extend, slice } = require "./utilities.coffee"

defaults = 
  identifyingAttribute: "id"


getLabel = do ->
  labels = document.getElementsByTagName( "input" )
  ( el ) ->
    for label in labels
      return label if label.control is el


class BaseControl
  constructor: ( el, options = {} ) ->
    return false unless el instanceof Element
    settings = extend( {}, defaults, options )
    @el = el
    @id = el.getAttribute( settings.identifyingAttribute )
    @type = el.type or el.tagName.toLowerCase()
    @tag = el.tagName.toLowerCase()


  required : ( param ) ->
    if param?
      @el.required = !!param
      return @
    return @el.required


  disabled : ( param ) ->
    if param?
      @el.disabled = !!param
      return @
    return @el.disabled


  value : ( param ) ->
    if param?
      @el.value = param
      return @
    else if @valid()
      return @el.value


  checked : -> undefined


  selected : -> undefined


  valid : ->
    if @el.checkValidity
      return @el.checkValidity()
    else
      return true


  clear : ->
    if @el.value
      @el.value = ""
      @dispatchEvent( "change" )
      

  addEventListener : ( eventType, handler ) ->
    fn = handler.bind( @ )
    @el.addEventListener( eventType, fn )
    fn
    

  removeEventListener : ( eventType, handler ) ->
    @el.removeEventListener eventType, handler


  dispatchEvent : ( evt ) ->
    if typeof evt is "string"
      evt = new Event evt,
        bubbles: true
    if evt instanceof Event
      @el.dispatchEvent( evt )
    else
      throw new TypeError( "Pass a string or Event object to dispatchEvent!" )


module.exports = BaseControl