do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  camelize = (str) ->
    camel = str.replace /(?:^|[-_ ])(\w)/g, (_, c) ->
      return if c then c.toUpperCase() else ""
    return camel.charAt(0).toLowerCase() + camel.slice(1)




  class Base
    constructor : ( el ) ->
      this.el = el
      this.id = el.id
      this.listeners = []
      return this

    value : ->
      if arguments.length
        return this._setValue( arguments )
      else
        return if this._hasValue() and this.validate() then this._getValue() else false

    values : ->
      return this.value( arguments )

    validate : ->
      return this.el.checkValidity()

    isFocused : ->
      return document.activeElement is this.el

    _hasValue : ->
      return !!this.el.value

    _setValue : ( value ) ->
      this.dispatchEvent new Event "change"
      return ( this.el.value = value )

    _getValue : ->
      return this.el.value

    _checkable : ->
      return "checked" of this.el

    addEventListener : ( type, listener, useCapture = false ) ->
      listener = listener.bind( this )
      this.el.addEventListener( type, listener, useCapture )
      this.listeners.push
        type: type
        listener: listener

    removeEventListener : ( type, listener, useCapture = false ) ->
      this.el.removeEventListener( type, listener, useCapture )
      return listener

    dispatchEvent : ( event ) ->
      this.el.dispatchEvent( event )




  class InputComponent extends Base
    constructor : ( el ) ->
      super( el )



  # This class is used for inputs matching [type="radio"] or [type="checkbox"]
  # It provides methods for getting 
  class CheckableComponent extends Base

    constructor : ( el ) ->
      super( el )

    check : -> 
      return this._switch( true )

    uncheck : ->
      return this._switch( false )

    _switch : ( bool ) ->
      if typeof bool is "undefined" or this.isChecked() isnt bool
        this.el.checked = !this.el.checked
        this.dispatchEvent new Event "change"
      return this.isChecked()

    isChecked : ->
      return this.el.checked

    value : ->
      if arguments.length
        this._setValue( arguments )
      else
        return if this.isChecked() then super() else return false




  class SelectComponent extends Base
    constructor : ( el ) ->
      super( el ) 

    value : ->
      return ( option.value for option in this.selected() )

    selected : ->
      options = this.el.querySelectorAll( "option" )
      Array.prototype.filter.call options, ( option ) ->
        return option.selected and not option.disabled



  # Array-like class that holds a group of inputs that should be logically connected
  class InputCollection extends Array
    constructor : ( selector ) ->
      if selector instanceof NodeList
        nodeList = selector
      else
        nodeList = document.querySelectorAll( selector )

      for node, i in nodeList
        this.push nodeList.item( i )
      return this

    push : ( el ) ->
      unless el instanceof Node
        if jQuery and el instanceof jQuery
          el = el[0]
        else if typeof el is "string"
          el = document.querySelector( el )
        else
          console.warn( "Invalid param passed to InputCollection::push") 
          return false

      super( InputFactory( el ) )

    value : ->
      results = ( val for input in this when val = input.value() )
      return if results.length then results else false

    values : ->
      return this.value( arguments )

    hashValue : ->
      results = {}
      for input in this  
        val = input.value()
        if val
          results[camelize(input.id)] = val
      return if Object.keys(results).length then results else false

    hashValues : ->
      return this.hashValues( arguments )

    addEventListener : ( type, listener, useCapture = false ) ->
      input.addEventListener( type, listener.bind( this ), useCapture ) for input in this
    
    inputById : ( id ) ->
      if id.charAt( 0 ) is "#"
        id = id.slice( 1 )
      for input in this
        return input if input.id is id
      return false

    check : ( param ) ->
      return this._changeCheck( true, param )

    uncheck : ( param ) ->
      return this._changeCheck( false, param )

    _changeCheck : ( onOff, param ) ->
      if typeof param is "undefined"
        for input in this when input instanceof CheckableComponent
          input[if onOff then "check" else "uncheck"]()
      else if typeof param is "number" and this[param] and this[param]._switch
        this[param][if onOff then "check" else "uncheck"]()
      else if typeof param is "string"
        if ( input = this.inputById( param ) )
          if input instanceof CheckableComponent
            input[if onOff then "check" else "f"]




  InputFactory = ( el ) ->
    classMatcher =
      input :
        radio : CheckableComponent
        checkbox: CheckableComponent
      select : SelectComponent

    if typeof el is "string"
      el = document.querySelectorAll( el )

    if el.length > 1
      return new InputCollection( el )
    else 
      if el.item
        el = el.item( 0 )
      switch el.tagName.toLowerCase()
        when "input" or "textarea"       
          constructor = ( classMatcher.input[ el.type ] or InputComponent )
          return new constructor( el )
        when "select"
          constructor = classMatcher.select
          return new constructor( el )
        else
          console.warn( "Invalid element passed to InputFactory" ) 
          return false

  InputBuilder = ( opts ) ->

    parent = do ->
      if opts.parent instanceof Node
        return opts.parent
      else if jQuery and opts.parent instanceof jQuery
        return opts.parent[0]
      else if typeof opts.parent is "string"
        return document.querySelector( opts.parent )

    nodes = []
    
    collection = new InputCollection()

    for el in opts.els
      do ->
        e = document.createElement( el.tagName )
        e.id = el.id or ""
        e.name = el.name or ""
        e.textContent = el.textContent or ""
        e.classList.add( cl ) for cl in el.classList
        if el.attr
          for attr in el.attr
            e.setAttribute( attr.name, attr.val )
        nodes.push( e )

        if e.tagName is "INPUT"
          collection.push( e )

    for node in nodes
      parent.appendChild( node )

    return collection 




  root.InputClasses =
    Base : Base
    InputComponent : InputComponent
    SelectComponent : SelectComponent
    CheckableComponent : CheckableComponent
    InputCollection : InputCollection
    InputFactory : InputFactory

