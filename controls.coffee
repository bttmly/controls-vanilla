# Polyfill Element::matches
if Element and not Element::matches
    p = Element::
    p.matches = p.matchesSelector || 
      p.mozMatchesSelector || 
      p.msMatchesSelector ||
      p.oMatchesSelector || 
      p.webkitMatchesSelector

controlValidations =   
  notEmpty : ->
    ( el ) -> !!el.value

  notEmptyTrim : ->
    ( el ) -> !!el.value.trim()

  numeric : ->
    ( el ) ->
      /^\d+$/.test el.value

  alphanumeric : ->
    ( el ) ->
      /^[a-z0-9]+$/i.test el.value

  letters : ->
    ( el ) -> 
      /^[a-z]+$/i.test el.value

  isValue : ( value ) ->
    ( el ) ->
      el.value is value

  phone : ->
    controlValidations.allowed( "1234567890()-+ " )

  email : ->
    i = document.createElement( "input" )
    i.type = "email"
    ( el ) ->
      i.value = el.value
      !!el.value and i.validity.valid

  list : ->
    ( el ) ->
      listValues = map ( el.list.options or [] ), ( option ) ->
        option.value or option.innerHTML
      el.value in listValues

  allowed : ( allowedChars ) ->
    allowedChars = allowedChars.split( "" )
    ( el ) ->
      str = el.value.split( "" )
      for char in str
        return false if char not in allowedChars
      return true

  notAllowed : ( notAllowedChars ) ->
    notAllowedChars = notAllowedChars.split( "" )
    ( el ) ->
      str = el.value.split( "" )
      for char in notAllowedChars
        return false if char in str
      return true

  numberBetween : ( min, max ) ->
    ( el ) ->
      min <= Number( el.value ) <= max

  numberMax : ( max ) ->
    controlValidations.numberBetween( 0, max )

  numberMin : ( min ) ->
    controlValidations.numberBetween( min, Number.POSITIVE_INFINITY )

  lengthBetween : ( min, max ) ->
    ( el ) ->
      min <= el.value.length <= max

  lengthMax : ( max ) ->
    controlValidations.lengthBetween( 0, max )

  lengthMin : ( min ) ->
    controlValidations.lengthBetween( min, Number.POSITIVE_INFINITY )

  lengthIs : ( len ) ->
    ( el ) ->
      el.value.length is Number( len )



elValid = do ->

  getMethod = ( str ) ->
    str?.split( "(" )[0]

  getArgs = ( str ) ->
    str?.match( /\(([^)]+)\)/ )?[ 1 ].split( "," ).map ( arg ) -> arg?.trim().replace(/'/g, "")

  ( el ) ->
    attr = el.dataset.controlValidation
    method = getMethod( attr )
    args = getArgs( attr )

    if method of controlValidations
      fn = controlValidations[method].apply( null, args )
      res = fn( el )
      res
    else
      el.validity.valid

# this is pretty rudimentary for now.
# definitely doesn't support multiselect
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

map = Function::call.bind( Array::map )
each = Function::call.bind( Array::forEach )
slice = Function::call.bind( Array::slice )
filter = Function::call.bind( Array::filter )



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
  
  # jank at the moment.
  trigger : ( evt ) ->
    unless evt instanceof Event
      evt = new CustomEvent evt,
        bubbles: true
        detail: {}
    @[0].dispatchEvent( evt )

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

  ( parentSelector ) ->
    parent = document.querySelector( parentSelector )
    controls = parent.querySelectorAll( controlTags.join( ", " ) )
    new ControlCollection( controls ) 

Factory.validate = elValid

Factory.addValidation = ( name, fn ) ->
  if controlValidations[ name ]
    return false
  controlValidations[ name ] = fn  

window.Controls = Factory