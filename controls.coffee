# Polyfills...
# Polyfill Element::matches
if Element and not Element::matches
    p = Element::
    p.matches = p.matchesSelector || 
      p.mozMatchesSelector || 
      p.msMatchesSelector ||
      p.oMatchesSelector || 
      p.webkitMatchesSelector

# Utilities...
# functional versions of Array prototype methods
map = Function::call.bind( Array::map )
each = Function::call.bind( Array::forEach )
slice = Function::call.bind( Array::slice )
filter = Function::call.bind( Array::filter )

# partical application
partial = ( fn ) ->
  args = slice( arguments, 1 )
  ->
    fn.apply @, args.concat( slice( arguments ) )

isFunction = ( obj ) ->
  obj and obj instanceof Function

controlValidations = do ->

  # http://benalman.com/news/2012/09/partial-application-in-javascript/#partial-application


  # nice short namespace by which refer to each other.
  v = 
    notEmpty : ( el ) -> !!el.value

    notEmptyTrim : ( el ) -> !!el.value.trim()

    numeric: ( el ) -> /^\d+$/.test el.value

    alphanumeric: ( el ) -> /^[a-z0-9]+$/i.test el.value

    letters: ( el ) -> /^[a-z]+$/i.test el.value

    isValue: ( value, el ) -> el.value is value

    phone: ( el ) -> v.allowed( "1234567890()-+ ", el )

    email: ( el ) ->
      i = document.createElement( "input" )
      i.type = "email"
      i.value = el.value
      !!el.value and i.validity.valid

    list: ( el ) ->
      listValues = map ( el.list.options or [] ), ( option ) ->
        option.value or option.innerHTML
      el.value in listValues

    allowed: ( allowedChars, el ) ->
        allowedChars = allowedChars.split( "" )
        str = el.value.split( "" )
        for char in str
          return false if char not in allowedChars
        return true

    notAllowed: ( notAllowedChars, el ) ->
      notAllowedChars = notAllowedChars.split( "" )
      str = el.value.split( "" )
      for char in notAllowedChars
        return false if char in str
      return true

    numberBetween: ( min, max, el ) ->
      Number( min ) <= Number( el.value ) <= Number( max )

    numberMax: ( max, el ) ->
      Number( el.value ) <= Number( max )

    numberMin: ( min, el ) ->
      Number( el.value ) >= Number( min )

    lengthBetween: ( min, max, el ) ->
      Number( min ) <= el.value.length <= Number( max )

    lengthMax: ( max, el ) ->
      el.value.length <= Number( max )

    lengthMin: ( min, el ) ->
      el.value.length >= Number( min )

    lengthIs: ( len, el ) ->
      el.value.length is Number( len )

  # return our validations out of this IIFE
  v


elValid = do ->

  getMethod = ( str ) ->
    str?.split( "(" )[0]

  getArgs = ( str ) ->
    str?.match( /\(([^)]+)\)/ )?[ 1 ].split( "," ).map ( arg ) -> arg?.trim().replace(/'/g, "")

  ( el ) ->
    attr = el.dataset.controlValidation
    method = getMethod( attr )
    args = getArgs( attr ) or []
    args.push( el )
    if method of controlValidations
      controlValidations[method].apply( null, args )
    else
      el.validity.valid

# this is pretty rudimentary for now.
# definitely doesn't support multi select
elValue = ( el ) ->
  if el.matches( "input[type=radio]" ) or el.matches( "input[type=checkbox]" )
    if el.checked then el.value else false
  else if el.matches( "select" )
    if el.selectedOptions[0].disabled is false then el.selectedOptions[0].value else false
  else if el.matches( "button" )
    false
  else if el.matches( "input" )
    el.value
  else
    false

# Clear the value or checked state or what-have-you from a control.
elClear = ( el ) ->
  changed = false
  if el.matches( "[type=radio]" ) or el.matches( "[type=checkbox]" )
    if el.checked
      el.checked = false
      changed = true
  else if el.matches( "select" )
    if el.selectedOptions.length
      each el.selectedOptions, ( option ) -> option.selected = false
      changed = true
  else if el.matches( "input" )
    if el.value
      el.value = ""
      changed = true
  return changed

validEvent = -> new Event "valid", 
  bubbles: true

changedEvent = -> new Event "changed",
  bubbles: true

class window.ValueObject extends Array
  constructor: ( arr ) ->
    # can do further checking for well formed value object
    if Array.isArray( arr )
      [].push.apply( @, arr )
    else
      throw new TypeError( "Pass an array to the ValueObject constructor!" )

  normal: ->
    arr = []
    [].push.apply( arr, @ )
    arr

  valueArray: ->
    @map ( pair ) -> pair.value

  idArray: ->
    @map ( pair ) -> pair.id

  keyValue: ->
    o = {}
    o[ pair.id ] = pair.value for pair in @
    o

  valueString: ( delimiter = ", " ) ->
    @valueArray().join( delimiter )

  valueArrayOne: ->
    m = @valueArray()
    if m.length > 1 then m else m[0]

  idArrayOne: ->
    m = @idArray()
    if m.length > 1 then m else m[0]

  at: ( i ) -> @[i].value

  first: -> @at( 0 )

  last: -> @at( @length - 1 )

  serialize: -> JSON.stringify @normal()



class ControlCollection extends Array
  constructor: ( elements ) ->
    [].push.apply( @, elements )

  value: ->
    values = []
    for control in @
      v = elValue( control )
      if v
        o = {}
        o.id = control.id
        o.value = v
        values.push( o )
    new ValueObject( values )

  valid: ->
    @every ( el ) -> elValid( el )

  filter : ->
    args = slice( arguments )
    if typeof args[0] is "string"
      selector = args[0]
      args[0] = ( control ) ->
        control.matches( selector )
    new ControlCollection Array::filter.apply( @, args )

  not: ->
    args = slice( arguments )
    fn = args.shift()
    if typeof fn is "string"
      notFn = ( e ) -> !e.matches( fn )
    else
      notFn = ( e ) -> !fn( e )
    args.unshift( notFn )
    new ControlCollection Array::filter.apply( @, args )

  tag: ( tag ) ->
    new ControlCollection @filter ( el ) ->
      el.tagName.toLowerCase() is tag.toLowerCase

  type: ( type ) ->
    new ControlCollection @filter ( el ) ->
      el.type.toLowerCase() is type.toLowerCase()

  clear: ( param ) ->
    for control in @
      control.dispatchEvent( changedEvent() ) if elClear( control )
    @

  disabled: ( param ) ->
    return @ unless param?
    control.disabled = !!param for control in @
    @

  required: ( param ) ->
    return @ unless param?
    control.required = !!param for control in @
    @

  checked: ( param ) ->
    return @ unless param?
    for control in @
      control.checked = !!param if "checked" of control
    @

  on: ( eventType, handler ) ->
    @setValidityListener() if eventType is "valid"
    eventHandler = ( event ) =>
      if event.target in @
        handler.bind( @ )( event )
    document.addEventListener( eventType, eventHandler )
    eventHandler

  off: ( eventType, handler ) ->
    document.removeEventListener( eventType, handler )
  
  # jank at the moment, but avoids triggering it on each element.
  # to do: use detail.id w/ array of already handled events to avoid this.
  trigger : ( evt ) ->
    unless evt instanceof Event
      evt = new CustomEvent evt,
        bubbles: true
        detail: {}
    @[0].dispatchEvent( evt )

  invoke: ( fn, args... ) ->
    for control in @
      if fn of control and isFunction control[fn]
        control[fn]( args )

  mapIdToProp : ( prop ) ->
    a = []
    for control in @
      o = {}
      o.id = control.id
      o[prop] = control[prop]
      a.push( o )
    new ValueObject( a )

  setValidityListener : do ->
    validityListener = false
    ->
      unless validityListener
        validityListener = true
        @on "change", ( event ) ->
          @trigger validEvent() if @valid() 
  
  # Non-essential for now.
  #
  # areDisabled: ->
  #   @mapIdToProp( "disabled" ) #returns ValueObject

  # areRequired: ->
  #   @mapIdToProp( "required" ) #returns ValueObject

  # areChecked: ->
  #   @mapIdToProp( "checked" ) #returns ValueObject


Factory = do ->

  controlTags = ["input", "select", "button", "textarea"]

  ( param ) ->

    controlElements = []

    inner = ( param ) ->
      
      if typeof param is "string"
        inner( document.querySelector( param ) )
        return

      else if param instanceof Element 
        
        if param.tagName.toLowerCase() not in controlTags
          inner param.querySelectorAll controlTags.join ", "
          return

        else
          controlElements.push( param )
          return

      else if param.length?
        each param, ( el ) -> inner( el )
        return

    inner( param )

    new ControlCollection( controlElements ) 

Factory.validate = elValid

Factory.addValidation = ( name, fn ) ->
  if controlValidations[ name ]
    return false
  controlValidations[ name ] = fn  

Factory.getValidations = -> controlValidations

window.Controls = Factory