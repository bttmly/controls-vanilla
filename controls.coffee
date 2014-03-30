do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

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
      @

    required : ( param ) ->
      if param
        @el.required = !!param
        return this
      else
        return @el.required

    disabled : ( param ) ->
      if param
        @el.disabled = !!param
        return this
      else
        return @el.disabled

    value : ( param ) ->
      if param
        @el.value = param
        return this
      else
        if @valid() then return @el.value else 

    valid : ->
      if @el.checkValidity
        return @el.checkValidity()
      else
        return true


    on : ( eventType, handler ) ->
      @el.addEventListener eventType, handler
      @

    off : ( handler ) ->
      @el.removeEventListener handler
      @

    trigger : ( eventType ) ->
      @el.dispatchEvent new CustomEvent eventType
      @

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
      return ( option.value for option in this.selected() )

    selected : ->
      opts = this.el.querySelectorAll( "option" )
      filter opts, ( opt ) ->
        return opt.selected and not opt.disabled

  class ButtonControl extends BaseControl
    constructor : ( el ) ->
      super( el )



  class ControlCollection extends Array
    constructor: ( components, options ) ->
      this.push( component ) for component in components
      this.id = options.id

    value : ->
      values = []
      for component in this
        val = component.value()
        if val and val.length then values.push
          id: component.id
          val: val
      return values

    valueHash : ->
      values = []
      for component in this
        values.push component.value()
      return values

    disabled : ( param ) ->
      results = {}
      for component in this
        if param then component.disabled( param )
        results[component.id] = component.disabled()
      return results

    required : ( param ) ->
      results = {}
      for component in this
        if param then component.required( param )
        results[component.id] = component.required()
      return results

    on : ( eventType, handler ) ->
      handler = handler.bind( this )
      for component in this
        component.on( eventType, handler )
      return this

    off : ( handler ) ->
      if ( index = this.listeners.indexOf( handler ) ) > -1
        this.listeners.splice index, 1
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
        return component if component.id
      return false



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

  Factory = ( e, options ) ->

    components = []
    tagNames = ["INPUT", "SELECT", "BUTTON"]

    factoryInner = ( elParam ) ->

      console.log "inner started"
      console.log elParam

      # "Branch 1"
      if elParam instanceof ControlCollection
        console.log "in ControlCollection"
        console.log elParam

        components.push elParam
        return

      # "Branch 2"
      else if typeof elParam is "string"
        console.log "in string"
        console.log elParam

        factoryInner qsa elParam
        return 

      # "Branch 6"
      else if elParam instanceof Node and not ( elParam.tagName in tagNames )
        console.log "in other node"
        console.log elParam

        els = []
        each tagNames, ( name ) ->
          console.log "Each tagName for:"
          console.log name

          group = elParam.getElementsByTagName name

          console.log group
          els = els.concat group
          return

        console.log "control children of otherNode"
        console.log els

        factoryInner els
        return

      # "Branch 5"
      else if elParam instanceof Node
        console.log "in control node"
        console.log elParam

        components.push buildControlObject elParam
        return

      # "Branch 3"
      # Confusingly, a Select node has length.
      else if typeof elParam.length isnt "undefined"
        console.log "in length"
        console.log elParam

        each elParam, ( item ) ->
          console.log "in each"
          console.log item

          factoryInner item
          return
        return
      
      else
        console.log "FELL THROUGH!!!"
        console.log elParam

      return

    factoryInner( e )


    options or= {}
    buildOptions = {}

    if typeof e is "string"
      buildOptions.id = e.substr 1

    return new ControlCollection components, buildOptions

  # User can configure this.
  Factory.identifyingAttribute = "id"

  root.Controls = Factory