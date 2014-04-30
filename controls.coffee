# Controls.coffee
# v0.2.0
# Nick Bottomley, 2014
# MIT License

( ( root, factory ) ->
  if typeof define is "function" and define.amd
    define [
      "exports"
    ], ( exports ) ->
      root.Controls = factory( root, exports )
      return

  else if typeof exports isnt "undefined"
    factory( root, exports )

  else
    root.Controls = factory( root, {} )

  return

)( this, ( root, Controls ) ->

  qs = document.querySelector.bind( document )
  qsa = document.querySelectorAll.bind( document )

  each = Function.prototype.call.bind( Array.prototype.forEach )
  slice = Function.prototype.call.bind( Array.prototype.slice )
  filter = Function.prototype.call.bind( Array.prototype.filter )

  # returns an true array of DOM nodes.
  querySelectorAll = ->
    if arguments[0] instanceof Node
      el = arguments[0]
      selector = arguments[1]
    else
      el = document
      selector = arguments[0]
    Array.prototype.slice.call el.querySelectorAll selector


  # for any input that doesn't match other controls
  class BaseControl
    constructor: ( el ) ->
      @el = el
      @id = el.id
      @listeners = []

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

  # for input[type='checkbox'] and input[type='radio']
  class CheckableControl extends BaseControl
    value : ( param ) ->
      if param
        @el.value = param
        @
      else
        return if @el.checked then @el.value else false


  # for <select>
  class SelectControl extends BaseControl
    value : ->
      results = []
      for option in this.selected()
        if option.value then results.push( option.value )
      return results

    selected : ->
      filter this.el.querySelectorAll( "option" ), ( opt ) ->
        return opt.selected and opt.value and not opt.disabled

  # for <button> and input[type='button']
  class ButtonControl extends BaseControl



  # an array-like object containing Control instances
  class ControlCollection extends Array
    constructor: ( components, options ) ->
      this.push( component ) for component in components
      this.id = options.id
      this.listners = {}

    value : ->
      values = []
      for component in this
        val = component.value()
        if val and val.length then values.push
          id: component.id
          val: val
      return values

    disabled : ( param ) ->
      results = {}
      for component in this
        if param? then component.disabled( param )
        results[component.id] = component.disabled()
      return results

    required : ( param ) ->
      results = {}
      for component in this
        if param? then component.required( param )
        results[component.id] = component.required()
      return results

    on : ( eventType, handler ) ->
      handler = handler.bind( @ )
      for component in @
        component.on( eventType, handler )
      @

    off : ->
      for component in @
        component.off( arguments )
      @

    trigger : ( eventType, handler ) ->
      handler = handler.bind( @ )
      for component in @
        component.trigger( arguments )
      @

    where : ( obj ) ->
      ret = []
      for component in @
        match = true
        for key, val of obj
          match = false if component[key] isnt val
        ret.push component if match is true

    find : ( obj ) ->
      for component in @
        match = true
        for key, val of obj
          match = false if component[key] isnt val
        return component if match is true

    byId : ( id ) ->
      @find( id: id )

    toFormData : ->
      formData = new FormData()
      for control in @
        formData.append control.id, control.value()
      return formData




    # filter : ->
    #   return controlFactory super

    _addListener : ( eventType, listener ) ->
      unless @listeners[eventType]
        @listeners[eventType] = []
      @listeners[eventType].push listener


  # for method in ["filter", "slice", "splice"]
  #   do ( method ) ->
  #     ControlCollection::[method] = ->
  #       Array.prototype[method].apply( this, arguments )


  # for evt in ["blur", "focus", "click", "dblclick", "keydown", "keypress", "keyup", "change", "mousedown", "mouseenter", "mouseleave", "mousemove", "mouseout", "mouseover", "mouseup", "resize", "scroll", "select", "submit"]
  #   do ( evt ) ->

  buildControlObject = ( el ) ->
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
        return



  controlFactory = ( e, options ) ->

    components = []
    tagNames = ["INPUT", "SELECT", "BUTTON"]

    factoryInner = ( elParam ) ->

      if elParam instanceof ControlCollection or elParam instanceof BaseControl
        components.push elParam
        return

      else if typeof elParam is "string"
        factoryInner qsa elParam
        return

      else if elParam instanceof Node and not ( elParam.tagName in tagNames )
        els = []
        each tagNames, ( name ) ->
          els = els.concat slice elParam.getElementsByTagName name
          return
        factoryInner els
        return

      else if elParam instanceof Node
        components.push buildControlObject elParam
        return

      else if typeof elParam.length isnt "undefined"
        each elParam, ( item ) ->
          factoryInner item
          return
        return
      
      else
        console.warn "Factory call fell through."

      return

    factoryInner( e )
    options or= {}
    buildOptions = {}
    buildOptions.id = options.id or do ->
      if e instanceof Node
        return e.getAttribute controlFactory.identifyingAttribute
      else if typeof e is "string"
        if e.charAt 0 is "#" or e.charAt 0 is "."
          return e.substr 1
        else
          return e

    console.log components

    return new ControlCollection( components, buildOptions )

  controlFactory.identifyingAttribute = "id"
  controlFactory.version = "0.2.0"

  controlFactory.BaseControl = BaseControl
  controlFactory.SelectControl = SelectControl
  controlFactory.ButtonControl = ButtonControl
  controlFactory.CheckableControl = CheckableControl
  controlFactory.ControlCollection = ControlCollection

  return controlFactory

)