util = require "./utilities.coffee"

extend = util.extend

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


  on : ( eventType, handler ) ->
    @el.addEventListener eventType, handler
    return @


  off : ( handler ) ->
    @el.removeEventListener handler
    return @


  trigger : ( eventType ) ->
    @el.dispatchEvent new CustomEvent eventType
    return @


module.exports = BaseControl