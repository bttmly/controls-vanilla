util = require "./utilities.coffee"
extend = util.extend

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
    results = {}
    for component in @
      if param? then component.disabled( param )
      results[component.id] = component.disabled()
    return results

  required : ( param ) ->
    results = {}
    for component in this
      if param? then component.required( param )
      results[component.id] = component.required()
    return results

  on : ( eventType, handler ) ->
    handler = handler.bind( @ )
    for component in @
      component.on( eventType, handler )
    @

  off : ->
    for component in @
      component.off( arguments )
    @

  trigger : ( eventType, handler ) ->
    handler = handler.bind( @ )
    for component in @
      component.trigger( arguments )
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