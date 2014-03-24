class InputBase
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

# TODO
# This needs some work. Figure out how to pass a reference to the input object. Right now you can only refer to the input HTML element.
["addEventListener", "dispatchEvent", "removeEventListener"].forEach ( method ) ->
  InputBase::[method] = ->
    EventTarget::[method].apply( this.el, arguments )

class InputComponent extends InputBase
  constructor : ( el ) ->
    super( el )

class CheckableComponent extends InputBase
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

class SelectComponent extends InputBase
  constructor : ( el ) ->
    super( el ) 

  value : ->
    return ( option.value for option in this.selected() )

  selected : ->
    options = this.el.querySelectorAll( "option" )
    Array.prototype.filter.call options, ( option ) ->
      return option.selected and not option.disabled

window.InputGroup = class InputGroup
  constructor : ( selector ) ->
    nodeList = document.querySelectorAll( selector )
    this.inputs = []
    for node, i in nodeList
      this.inputs.push InputMaker nodeList.item( i )
    return this

  value : ->
    results = []
    for input in this.inputs  
      val = input.value()
      if val
        results.push( val )
    return results

  values : ->
    return this.value()


window.InputMaker = class InputMaker

  classMatcher =
    input :
      radio : CheckableComponent
      checkbox: CheckableComponent
    select : SelectComponent

  constructor : ( el ) ->
    if typeof el is "string"
      el = document.querySelector( el )

    switch el.tagName.toLowerCase()
      when "input" or "textarea"       
        constructor = ( classMatcher.input[ el.type ] or InputComponent )
        return new constructor( el )
      when "select"
        constructor = classMatcher.select
        return new constructor( el )
      else
        console.warn( "Invalid element passed to InputMaker" ) 
        return false

