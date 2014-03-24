do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  class Base
    constructor : ( el ) ->
      this.el = el
      return this

    value : ->
      if arguments.length
        return this._setValue( arguments )
      else
        return if this._hasValue() and this.validate() then this.el.value else false

    values : ->
      return this.value( arguments )

    validate : ->
      return true

    isFocused : ->
      return document.activeElement is this.el

    _hasValue : ->
      return !!this.el.value

    _setValue : ( value ) ->
      return ( this.el.value = value )

    # returns the bound function so you can store it and use it to remove the listener later.
    addEventListener : ( type, listener, useCapture = false ) ->
      listener = listener.bind( this )
      this.el.addEventListener( type, listener, useCapture )
      return listener

    removeEventListener : ( type, listener, useCapture = false ) ->
      this.el.removeEventListener( type, listener, useCapture )
      return listener

    dispatchEvent : ( event ) ->
      this.el.dispatchEvent( event )

  class InputComponent extends Base
    constructor : ( el ) ->
      super( el )

  class CheckableComponent extends Base

    constructor : ( el ) ->
      super( el )

    checked : -> 
      return this.el.checked

    value : ->
      if arguments.length
        this._setValue( arguments )
      else
        return if this.checked() then super() else return false

    toggle : ->
      this.checked = !this.checked

  class SelectComponent extends Base
    constructor : ( el ) ->
      super( el ) 

    value : ->
      return ( option.value for option in this.selected() )

    selected : ->
      options = this.el.querySelectorAll( "option" )
      Array.prototype.filter.call options, ( option ) ->
        return option.selected and not option.disabled

  class InputGroup
    constructor : ( selector ) ->
      if selector instanceof NodeList
        nodeList = selector
      else
        nodeList = document.querySelectorAll( selector )
      this.inputs = []
      for node, i in nodeList
        this.inputs.push InputFactory nodeList.item( i )
      return this

    value : ->
      results = []
      for input in this.inputs  
        val = input.value()
        if val
          results.push( val )
      return results

    values : ->
      return this.value( arguments )


  InputFactory = ( el ) ->
    classMatcher =
      input :
        radio : CheckableComponent
        checkbox: CheckableComponent
      select : SelectComponent

    if typeof el is "string"
      el = document.querySelectorAll( el )

    if el.length > 1
      return new InputGroup( el )
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

  root.InputClasses =
    Base : Base
    InputComponent : InputComponent
    SelectComponent : SelectComponent
    CheckableComponent : CheckableComponent
    InputGroup : InputGroup
    InputFactory : InputFactory

