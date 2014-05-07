{ 
  extend, 
  isEmpty, 
  each, 
  mapToObject 
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
    controls = []
    @collections = {}
    for component in components
      if component instanceof ControlCollection
        @collections[ component.id ] = component
        [].push.apply( @, component )
      else
        @push component

    settings = extend( {}, ControlCollection.defaults(), options )
    @id = settings.id
    if settings.valid
      if typeof settings.valid is "string"
        @valid = ->
          validation[ settings.valid ]( @el.value )



  value : ->
    values = {}
    for component in @
      val = component.value()
      if val and val.length
        values[ component.id ] = val
    values


  valueAsArray : ->
    values = []
    for component in @
      val = component.value()
      if val and val.length then values.push
        id: component.id
        val: val
    values


  disabled : ( param ) ->
    mapToObject @, ( component ) ->
      if param? then component.disabled( param )
      [ component.id, component.el.disabled ]


  required : ( param ) ->
    mapToObject @, ( component ) ->
      if param? then component.required( param )
      [ component.id, component.el.required ]


  checked : ( param ) ->
    mapToObject @, ( component ) ->
      if param? then component.checked( param )
      [ component.id, component.el.checked ]



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


  on : ( eventType, handler ) ->
    handler = handler.bind( @ )
    for component in @
      component.on( eventType, handler )
    @


  off : ->
    for component in @
      component.off( arguments )
    @


  trigger : ( eventType ) ->
    for component in @
      component.trigger( eventType )
    @


  where : ( obj ) ->
    ret = []
    for component in @
      match = true
      for key, val of obj
        match = false if component[key] isnt val
      ret.push component if match is true


  find : ( obj ) ->
    for component in @
      match = true
      for key, val of obj
        match = false if component[key] isnt val
      return component if match is true


  byId : ( id ) ->
    @find( id: id )


module.exports = ControlCollection