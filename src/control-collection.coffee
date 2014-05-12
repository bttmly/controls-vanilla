{ 
  extend, 
  isEmpty, 
  each, 
  mapToObj 
} = require "./utilities.coffee"

validation = require "./validation.coffee"

class ControlCollection extends Array


  @defaults : do ->
    counter = 0
    ->
      id : do ->
        counter += 1
        return "controlCollection#{ counter }"

  constructor: ( components, options ) ->
    @collections = {}
    for component in components
      if component instanceof ControlCollection
        @collections[ component.id ] = component
        @push.apply( @, component )
      else
        @push( component )
    @els = @map ( c ) -> c.el

    settings = extend( {}, ControlCollection.defaults(), options )
    @id = settings.id

  # Should be set to either "valueAsObject" or "valueAsArray"
  # Setting this property with the options object in the constructor
  # will override this class default.
  defaultValue: "valueAsObject"

  value : -> @[@defaultValue]()

  # returns an object with key/value pairs representing the element's id
  # and it's value
  valueAsObject : ->
    values = {}
    for component in @
      val = component.value()
      if val and val.length
        values[ component.id ] = val
    values

  # returns an array of objects. Each object has an 'id' key representing
  # the element's id, and a 'val' key representing the value.
  valueAsArray : ->
    values = []
    for component in @
      val = component.value()
      if val and val.length then values.push
        id: component.id
        val: val
    values

  # ::disabled, ::required, and ::checked all follow the same jQuery-like
  # pattern. Calling with an argument SETS, while calling without GETS.
  # When setting, you get the collection returned for chaining.
  # When getting, you get an object representing the state of that property
  # on each component
  disabled : ( param ) ->
    m = mapToObj @, ( component ) ->
      if param? then component.disabled( param )
      [ component.id, component.disabled() ]
    if param then @ else m

  required : ( param ) ->
    m = mapToObj @, ( component ) ->
      if param? then component.required( param )
      [ component.id, component.required() ]
    if param then @ else m

  checked : ( param ) ->
    m = mapToObj @, ( component ) ->
      if param? then component.checked( param )
      [ component.id, component.checked() ]
    if param then @ else m

  clear : ->
    component.clear() for component in @
    @


  # For ::valid, we want to check any sub-collections of this collection
  # for validity AS A GROUP. Sub-collections can have custom validity
  # rules, so the collection might be valid even if it has invalid components.
  # After that, we want to check any Controls in this collection on individual 
  # basis. We do this by checking if each control is in a sub-collection we've
  # already covered; if so, we don't need to check it's individual validity.
  # We return true only if all singles and all collections are valid.
  valid : ->
    checkedInSubCollection = []
    collectionsValid = true
    each @collections, ( collection ) ->
      checkedInSubCollection.push.apply( checkedInSubCollection, collection )
      collectionsValid = false unless collection.valid()

    singlesValid = true
    for control in @
      continue if control in checkedInSubCollection
      singlesValid = false unless control.valid()

    return collectionsValid and singlesValid

  # Listens for events on the Collection's controls
  # Returns the listener so it can be saved and later removed.
  # Handler context defaults to this collection; special string
  # values "target" and "control" can change it, (or can be set to whatever).
  addEventListener : ( eventType, handler, context = @ ) ->
    fn = ( event ) =>
      if event.target in @els
        if context is "target"
          t = event.target
        else if context is "control"
          t = @find el: event.target
        else
          t = context
        handler.call( t, event )
    document.addEventListener( eventType, fn )
    fn


  removeEventListener : ( eventType, handler ) ->
    document.removeEventListener( eventType, handler )


  dispatchEvent : ( evt ) ->
    if typeof evt is "string"
      evt = new Event( evt )
    if evt instanceof Event
      el.dispatchEvent( evt ) for el in @els
    else
      throw new TypeError "Pass a string or Event object to dispatchEvent()!"


  # can combine where and find functionality into one method
  # where and find operate like their Underscore analogs.
  where : ( obj ) ->
    ret = []
    for component in @
      match = true
      for key, val of obj
        match = false if component[key] isnt val
      ret.push component if match
    ret


  find : ( obj ) ->
    for component in @
      match = true
      for key, val of obj
        match = false if component[key] isnt val
      return component if match
    return false


  byId : ( id ) ->
    @find( id: id )





module.exports = ControlCollection