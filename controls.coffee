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
  idx = arr.indexOf( value )
  if idx > 0
    arr.splice( idx, 1 )
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
    notEmpty : ( el ) -> !!el.value

    notEmptyTrim : ( el ) -> !!el.value.trim()

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
        $_( "input[type='radio'][name='#{name}']" ).some ( input ) -> input.checked
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
    if el.selectedOptions[0].disabled is false then el.selectedOptions[0].value else false
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



# Functions to generate events we'll be triggering often.
# If addding event id's, change to "new CustomEvent", and use details: {}
# TODO: create general event producer to ensure all events bubble?
validEvent = -> new Event "valid", 
  bubbles: true

invalidEvent = -> new Event "invalid",
  bubbles: true

changedEvent = -> new Event "changed",
  bubbles: true


# Return value of ControlCollection::value() is an instance of this class
# Has handy methods for transforming value into more palatable structure
class window.ValueObject extends Array
  constructor: ( arr ) ->
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

  idValuePair: ->
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
    @_setValidityListener = false
    @_eventListeners = {}
    [].push.apply( @, elements )

  value: ->
    # consider IF and HOW to handle get/set signatures
    # if arguments.length then return @setValue( arguments ) else @getValue()
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
    every @, ( el ) -> elValid( el )

  # filter controls and return result as ControlCollection
  # if passed a string, uses it as a CSS selector to match against controls
  filter : ->
    args = slice( arguments )
    if typeof args[0] is "string"
      selector = args[0]
      args[0] = ( control ) ->
        control.matches( selector )
    new ControlCollection Array::filter.apply( @, args )

  # inverse of @filter
  not: ->
    args = slice( arguments )
    fn = args.shift()
    if typeof fn is "string"
      notFn = ( e ) -> !e.matches( fn )
    else
      notFn = ( e ) -> !fn( e )
    args.unshift( notFn )
    new ControlCollection Array::filter.apply( @, args )

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
  # TODO: Any way to revert to hardcoded default values (value="xyz")?
  clear: ->
    for control in @
      control.dispatchEvent( changedEvent() ) if elClear( control )
    @

  # these do nothing if no param is passed.
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

  # add an event listener.
  # Adds listener to document and checks matching events to see if 
  # their target is in this collection
  # Returns the listener b/c it's bound to collection and can't be saved
  # for later removal otherwise
  on: ( eventType, handler ) ->
    @setValidityListener() if eventType is "valid"
    eventHandler = ( event ) =>
      if event.target in @
        handler.bind( @ )( event )
    document.addEventListener( eventType, eventHandler )
    @_eventListeners[ eventType ] or= []
    @_eventListeners[ eventType ].push( eventHandler )
    eventHandler

  # Remove a previously attached event listener.
  off: ( eventType, handler ) ->
    document.removeEventListener( eventType, handler )
    listeners = @_eventListeners[ eventType ] or []
    remove( listeners, handler )

  # Remove all listeners for a given event type, or if no type is passed,
  # all listeners on the collection.
  offAll : ( eventType ) ->
    list = if eventType then [ eventType ] else Object.keys( @_eventListeners )
    each list, ( type ) =>
      listeners = @_eventListeners[ type ] or []
      each listeners, ( fn ) =>
        @off( type, fn )

  # Super jank at the moment, but avoids triggering it on each element.
  # to do: use detail.id w/ array of already handled events to avoid this.
  trigger : ( evt ) ->
    unless evt instanceof Event
      evt = new CustomEvent evt,
        bubbles: true
        detail: {}
    @[0].dispatchEvent( evt )

  # call a function or method on each control
  # function is called in context of control
  invoke: ( fn, args... ) ->
    for control in @
      if typeof fn is "string"
        if fn of control and isFunction control[fn]
          control[fn]( args )
      else if isFunction( fn )
        fn.apply( control, args )
    @

  labels: ->
    labels = []
    for control in @
      [].push.apply( labels, control.labels )
    labels

  mapIdToProp: ( prop ) ->
    a = []
    for control in @
      o = {}
      o.id = control.id
      o[prop] = control[prop]
      a.push( o )
    new ValueObject( a )

  
  setValidityListener : ->
    # Will only set validity listeners once per collection.
    unless @_validityListener
      @_validityListener = true
      @on "change", ( event ) ->
        if @valid() then @trigger validEvent() else @trigger invalidEvent()
      @on "input", ( event ) ->
        if @valid() then @trigger validEvent() else @trigger invalidEvent() 
      @trigger "change"


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

# This is the only way to set validations, they're not available directly
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