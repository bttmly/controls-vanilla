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
    
  class BaseControl
    constructor: ( el ) ->
      @el = el
      @id = el.id
      @listeners = []

    required : ( param ) ->
      if arguments.length
        @el.required = !!param
        return @
      else
        return @el.required

    disabled : ( param ) ->
      if arguments.length
        @el.disabled = !!param
        return @
      else
        return @el.disabled

    value : ( param ) ->
      if arguments.length
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

  class CheckableControl extends BaseControl
    constructor : ( el ) ->
      super( el )

    value : ( param ) ->
      if param
        @el.value = param
        return this
      else 
        return if @el.checked then @el.value else false

  class SelectControl extends BaseControl
    constructor : ( el ) ->
      super( el ) 

    value : ->
      results = []
      for option in this.selected()
        if option.value then results.push( option.value )
      return results

    selected : ->
      filter this.el.querySelectorAll( "option" ), ( opt ) ->
        return opt.selected and opt.value and not opt.disabled

  class ButtonControl extends BaseControl
    constructor : ( el ) ->
      super( el )





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

    valueArray : ( deep ) ->
      values = []
      for component in this
        if deep 
          values.push( component.valueArray() or component.value() )
        else
          values.push component.value()
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
      handler = handler.bind( this )
      for component in this
        component.on( eventType, handler )
      return this

    off : ( handler ) ->
      # if ( index = this.listeners.indexOf( handler ) ) > -1
      #   this.listeners.splice index, 1
      for component in this
        component.off( arguments )
      return this

    trigger : ( eventType, handler ) ->
      handler = handler.bind( this )
      for component in this
        component.trigger( arguments )
      return this

    getComponentById : ( id ) ->
      for component in this
        return component if component.id is id
      return false

    _addListener : ( eventType, listener ) ->
      unless this.listeners[eventType]
        this.listeners[eventType] = []
      this.listeners[eventType].push( listener )



  buildControlObject = ( el ) ->
    switch el.tagName
      when "INPUT"
        if el.type is "radio" or el.type is "checkbox"
          return new CheckableControl el
        else
          return new BaseControl el
      when "SELECT"
        return new SelectControl el
      when "BUTTON"
        return new ButtonControl el
      else
        return

  controlFactory = ( e, options ) ->

    components = []
    tagNames = ["INPUT", "SELECT", "BUTTON"]

    factoryInner = ( elParam ) ->

      if elParam instanceof ControlCollection
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

    return new ControlCollection( components, buildOptions )

  controlFactory.identifyingAttribute = "id"
  controlFactory.version = "0.2.0"

  return controlFactory

)