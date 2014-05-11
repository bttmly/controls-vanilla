{ extend } = require "./utilities.coffee"

defaults = 
  identifyingAttribute: "id"

class BaseControl
  constructor: ( el, options = {} ) ->
    settings = extend( {}, defaults, options )
    unless el instanceof Element
      console.log el
    @el = el
    @id = el.getAttribute settings.identifyingAttribute
    @type = el.type or el.tagName.toLowerCase()
    @tag = el.tagName.toLowerCase()

  required : ( param ) ->
    if param?
      @el.required = !!param
      return @
    else
      return @el.required


  disabled : ( param ) ->
    if param?
      @el.disabled = !!param
      return @
    else
      return @el.disabled


  value : ( param ) ->
    if param?
      @el.value = param
      return @
    else if @valid()
      return @el.value


  valid : ->
    if @el.checkValidity
      return @el.checkValidity()
    else
      return true


  clear : ( squelchEvent ) ->
    if @el.value
      @el.value = ""
      @dispatchEvent "change"
      


  addEventListener : ( eventType, handler ) ->
    handler = handler.bind( @ )
    @el.addEventListener eventType, handler
    handler
    

  removeEventListener : ( eventType, handler ) ->
    @el.removeEventListener handler


  dispatchEvent : ( evt ) ->
    if typeof evt is "string"
      evt = new Event evt,
        bubbles: true
    if evt instanceof Event
      @el.dispatchEvent evt
    else
      throw new TypeError "Pass a string or Event object to dispatchEvent!"


module.exports = BaseControl