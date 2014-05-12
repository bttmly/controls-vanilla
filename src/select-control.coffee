BaseControl = require "./base-control.coffee"
{ filter, each, mapOne } = require "./utilities.coffee"

class SelectControl extends BaseControl

  value : ->
    mapOne @selected(), ( option ) -> 
      option.value

  selected : ->
    filter @el.options, ( option ) ->
      option.selected and not option.disabled

  valid : ->
    !!@value().length

  clear : ->
    if @selected().length
      each @el.options, ( option ) ->
        option.selected = false
      @dispatchEvent "change"

module.exports = SelectControl