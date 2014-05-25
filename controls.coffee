# Polyfill Element::matches
if Element and not Element::matches
    p = Element::
    p.matches = p.matchesSelector || 
      p.mozMatchesSelector || 
      p.msMatchesSelector ||
      p.oMatchesSelector || 
      p.webkitMatchesSelector

# Utilities...
# Functional versions of Array prototype methods
# All of these return regular arrays
map = Function::call.bind( Array::map )
each = Function::call.bind( Array::forEach )
slice = Function::call.bind( Array::slice )
every = Function::call.bind( Array::every )
filter = Function::call.bind( Array::filter )

remove = ( arr, val ) ->
  i = arr.indexOf( val )
  arr.splice( i, 1 ) if i isnt -1
  arr

# Extend/clone
extend = ( out ) ->
  out or= {}
  i = 1
  while i < arguments.length
    continue unless arguments[i]
    for own key of arguments[i]
      out[key] = arguments[i][key]
    i++
  out

# Simple DOM selection function; returns a normal array
$_ = ( selector, context = document ) ->
  if typeof context is "string"
    context = document.querySelector( context )
  throw new TypeError( "Can't select with that context.") unless context instanceof Node
  slice context.querySelectorAll( selector )

isFunction = ( obj ) ->
  obj and obj instanceof Function

controlValidations = do ->

  # nice short namespace by which validations refer to each other.
  v = 
    notEmpty: ( el ) -> !!el.value

    notEmptyTrim: ( el ) -> !!el.value.trim()

    numeric: ( el ) -> /^\d+$/.test el.value

    alphanumeric: ( el ) -> /^[a-z0-9]+$/i.test el.value

    letters: ( el ) -> /^[a-z]+$/i.test el.value

    isValue: ( value, el ) -> String( el.value ) is String( value )

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
    
    radio: ( el ) ->
      if ( name = el.name )
        return $_( "input[type='radio'][name='#{name}']" ).some ( input ) -> input.checked
      # won't validate unnamed radios
      else
        false

    checkbox: ( minChecked = 0, maxChecked = 50, el ) ->
      if ( name = el.name )
        len = $_( "input[type='checkbox'][name='#{name}']" ).filter( ( input ) -> input.checked ).length
        return minChecked <= len <= maxChecked
      # will validate unnamed checkboxes
      else
        true

    select: ( min = 1, max = 1, el ) ->
      selected = filter el, ( opt ) -> opt.selected and not opt.disabled
      if min <= selected.length <= max then true else false

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



# elValid, elValue, and elClear are basically adapters for the various 
# controls we're working with. Much easier than working with intermediary classes.

# check if an element is valid
# tries to use [data-control-validation] with .validity as a fallback
elValid = do ->

  # TODO IMPORTANT: Add function to split composed validations by && / ||

  splitMethods = ( str ) ->
    str?.split( "&&" ).map ( m ) -> m?.trim()

  getMethod = ( str ) ->
    str?.split( "(" )[0]

  getArgs = ( str ) ->
    str?.match( /\(([^)]+)\)/ )?[ 1 ].split( "," ).map ( arg ) -> arg?.trim().replace(/'/g, "")

  # TODO add test for customFn
  ( el, customFn ) ->
    if customFn
      return customFn( el )
    else if ( attr = el.dataset.controlValidation )
      composed = splitMethods( attr )
      return composed.every ( str ) ->
        method = getMethod( str )
        args = getArgs( str ) or []
        sigLength = controlValidations[method].length
        args.length = if sigLength is 0 then 0 else sigLength - 1
        args.push( el )
        if method of controlValidations
          controlValidations[method].apply( null, args )
        else
          return false
    else
      el.validity.valid

# Get value of element.
# This is pretty rudimentary for now.
# definitely doesn't support multi select
elValue = ( el ) ->
  # only gets a value for a checkable if it's checked
  if el.matches( "input[type=radio]" ) or el.matches( "input[type=checkbox]" )
    if el.checked then el.value else false
  # get the first non-disabled selected option
  # no support for multi select currently
  else if el.matches( "select" )
    if not el.selectedOptions[0]?.disabled then el.selectedOptions[0]?.value else false
  # buttons don't have values
  else if el.matches( "button" ) or el.matches( "input[type='button']" )
    false
  # catches other control types
  else if el.matches( "input" ) or el.matches( "textarea" )
    el.value
  # false if we didn't catch it earlier
  else 
    false

# Clears the value or checked state or what-have-you from a control.
# If the element's value does actually change, we return true from this
# Which indicates that we should fire a "change" event.
elClear = ( el ) ->
  changed = false

  if el.matches( "[type=radio]" ) or el.matches( "[type=checkbox]" )
    if el.checked
      el.checked = false
      changed = true

  # Programmatically selecting/deselecting select options is a little weird.
  # This should work OK, but don't rely heavily on accurate "change" events 
  # for <select> at this point
  else if el.matches( "select" )
    if el.selectedOptions.length
      # save the original selected set
      originalSelected = el.selectedOptions
      # set set the selected property of each option to false
      each el.selectedOptions, ( option ) -> option.selected = false
      # if there are still selected items, check if anything has changed
      if el.selectedOptions.length is originalSelected.length
        # if every item in the origial selected set is in the 
        # current selected set, nothing changed
        changed = !every originalSelected, ( opt ) ->
          opt in el.selectedOptions

  else if el.matches( "input" )
    if el.value
      el.value = ""
      changed = true

  # lets ControlCollection::clear know if the value did in fact change   
  return changed



# Functions to generate and emit events we'll be using often.
# If addding event id's, change to "new CustomEvent", and use details: {}
# TODO: create general event producer to ensure all events bubble?
event = ( type ) -> new Event type, bubbles: true

trigger = ( target, type ) ->
  evt = event( type )
  method = if "trigger" of target then "trigger" else "dispatchEvent"
  target[ method ]( evt )

validEvent = -> event( "valid" )

invalidEvent = -> event( "invalid" )

changeEvent = -> event( "change" )
  


# Return value of ControlCollection::value() is an instance of this class
# Has handy methods for transforming value into more palatable structure
class window.ValueObject extends Array
  constructor: ( arr ) ->
    if Array.isArray( arr )
      [].push.apply( this, arr )
    else
      throw new TypeError( "Pass an array to the ValueObject constructor!" )

  normal: ->
    arr = []
    [].push.apply( arr, this )
    arr

  valueArray: ->
    @map ( pair ) -> pair.value

  idArray: ->
    @map ( pair ) -> pair.id

  idValuePair: ->
    o = {}
    o[ pair.id ] = pair.value for pair in this
    o

  valueString: ( delimiter = ", " ) ->
    @valueArray().join( delimiter )

  valueArrayOne: ->
    m = @valueArray()
    if m.length > 1 then m else m[0]

  idArrayOne: ->
    m = @idArray()
    if m.length > 1 then m else m[0]

  at: ( i ) -> 
    if isNaN Number( i )
      @idValuePair()[i]
    else
      @[i].value

  first: -> @at( 0 )

  last: -> @at( @length - 1 )

  serialize: -> JSON.stringify @normal()



class ControlCollection extends Array
  constructor: ( elements ) ->
    @_setValidityListener = false
    @_eventListeners = {}
    [].push.apply( this, elements )

  # .value(), .data(), and .prop() all behave similarly.
  # They have get and set call signatures and return ValueObjects
  #
  # Zero arguments: "get" signature
  # One argument: "set" signature
  value: ( param ) ->
    if param then @_setValue( param ) else @_getValue()

  # internal. Used for "get" signature of .value()
  _getValue: ->
    values = []
    for control in this
      v = elValue( control )
      if v
        o = {}
        o.id = control.id
        o.value = v
        values.push( o )
    new ValueObject( values )

  # internal. Used for "set" signature of .value()
  _setValue: ( param ) ->
    for control in this
      control.value = param if "value" of control
    this

  # One argument: "get" signature
  # Two arguments: "set" signature
  data: ( attr, val ) ->
    if val then @_setData( attr, val ) else @_getData( attr )

  # internal. Used for "get" signature of .data()
  _getData: ( attr ) ->
    data = []
    for control in this
      o = {}
      o.id = control.id
      o.value = control.dataset[ attr ]
      values.push( o )
    new ValueObject( data )

  # internal. Used for "set" signature of .data()
  _setData: ( attr, val ) ->
    for control in this
      control.dataset[ attr ] = val
    this

  # One argument: "get" signature
  # Two arguments: "set" signature
  prop: ( prop, val ) ->
    if prop is "value"
      return @value.apply( this, arguments )
    else
      if val then @_setData( attr, val ) else @_getData( attr )

  # internal. Used for "set" signature of .prop()
  _getProp: ( prop ) ->
    data = []
    for control in this
      o = {}
      o.id = control.id
      o.value = control[ attr ]
      values.push( o )
    new ValueObject( data )

  # internal. Used for "set" signature of .prop()
  _setProp: ( prop, val ) ->
    for control in this
      control[ attr ] = val if prop of control
    this


  valid: ->
    @every ( el ) -> elValid( el )

  # filter controls and return result as ControlCollection
  # if passed a string, uses it as a CSS selector to match against controls
  filter: ->
    args = slice( arguments )
    if typeof args[0] is "string"
      selector = args[0]
      args[0] = ( control ) ->
        control.matches( selector )
    new ControlCollection Array::filter.apply( this, args )

  # inverse of @filter
  not: ->
    args = slice( arguments )
    fn = args.shift()
    if typeof fn is "string"
      notFn = ( e ) -> !e.matches( fn )
    else
      notFn = ( e ) -> !fn( e )
    args.unshift( notFn )
    new ControlCollection Array::filter.apply( this, args )

  # filter shorthand for tagName
  tag: ( tag ) ->
    new ControlCollection @filter ( el ) ->
      el.tagName.toLowerCase() is tag.toLowerCase

  # filter shorthand for type
  type: ( type ) ->
    new ControlCollection @filter ( el ) ->
      el.type.toLowerCase() is type.toLowerCase()

  # Delegates to elClear to clear values
  # Triggers "change" event on any control whose value actually changes
  # Should use el.defaultValue?
  clear: ->
    for control in this
      control.dispatchEvent( changeEvent() ) if elClear( control )
    this

  # these do nothing if no param is passed.
  disabled: ( param ) ->
    return this unless param?
    control.disabled = !!param for control in this
    this

  required: ( param ) ->
    return this unless param?
    control.required = !!param for control in this
    this

  checked: ( param ) ->
    return this unless param?
    param = !!param
    for control in this
      if control.matches( "[type='radio'], [type='checkbox']" )
        unless control.checked is param
          control.checked = param
          trigger( control, "change" )
    this

  # add an event listener.
  # Adds listener to document and checks matching events to see if 
  # their target is in this collection
  # Returns the listener b/c it's bound to collection and can't be saved
  # for later removal otherwise
  on: ( eventType, handler ) ->
    @setValidityListener() if eventType is "valid"
    eventHandler = ( event ) =>
      if event.target in this
        handler.call( this, event )
    document.addEventListener( eventType, eventHandler )
    @_eventListeners[ eventType ] or= []
    @_eventListeners[ eventType ].push( eventHandler )
    eventHandler

  # Remove a previously attached event listener.
  off: ( eventType, handler ) ->
    remove ( @_eventListeners[ eventType ] or [] ), handler
    document.removeEventListener( eventType, handler )
  
  # Remove all listeners for a given event type, or if no type is passed,
  # all listeners on the collection.
  offAll: ( eventType ) ->
    list = if eventType then [ eventType ] else Object.keys( @_eventListeners )
    each list, ( type ) =>
      listeners = @_eventListeners[ type ] or []
      each listeners, ( fn ) =>
        @off( type, fn )

  # Super jank at the moment, but avoids triggering it on each element.
  # TODO: figure out a nice way to let a handler be called at most once
  # for a given event.
  trigger: ( evt ) ->
    unless evt instanceof Event
      evt = new CustomEvent evt,
        bubbles: true
        detail: {}
    @[0].dispatchEvent( evt )

  # call a function or method on each control
  # function is called in context of control
  invoke: ( fn, args... ) ->
    for control in this
      if typeof fn is "string"
        if fn of control and isFunction control[fn]
          control[fn]( args )
      else if isFunction( fn )
        fn.apply( control, args )
    this

  labels: ->
    labels = []
    for control in this
      [].push.apply( labels, control.labels )
    labels

  # TODO add test for invalid event.
  # Will only set validity listeners once per collection.
  setValidityListener: ->
    unless @_validityListener
      @_validityListener = true
      listener = -> @trigger( if @valid() then validEvent() else invalidEvent() )
      @on "change", listener
      @on "input", listener
      setTimeout =>
        @trigger "change"
      , 0

Factory = do ->

  controlTags = ["input", "select", "button", "textarea"]

  ( param ) ->

    # hold a reference to the control list we're building out here.
    controlElements = []

    inner = ( param ) ->
      
      # matches strings, duh
      if typeof param is "string"
        inner( document.querySelector( param ) )
        return

      # matches elements
      else if param instanceof Element 
        
        # checks if not a control element
        # get descendant controls and pass them back into this function NodeList
        if param.tagName.toLowerCase() not in controlTags
          inner param.querySelectorAll controlTags.join ", "
          return

        # push control elements into the array we're building
        else
          controlElements.push( param )
          return

      # matches instances of Array, NodeList, HTMLCollection, jQuery, ControlCollection, etc
      # passes each item in those array-like structures back into this function
      else if param.length?
        each param, ( el ) -> inner( el )
        return

    # kick off the inner function
    inner( param )

    new ControlCollection( controlElements ) 

# Run validation on any element. Useful mostly for testing
Factory.validate = elValid

# This is how to set validations; the object isn't exposed directly.
Factory.addValidation = ( name, fn ) ->
  if controlValidations[ name ]
    return false
  controlValidations[ name ] = fn

# Allow access to validation functions w/o letting them be altered
Factory.getValidations = -> 
  extend( {}, controlValidations )

# expose the ControlCollection constructor
Factory.init = ControlCollection

Factory.valueInit = ValueObject

# expose factory as the namespace
window.Controls = Factory