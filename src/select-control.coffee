BaseControl = require "./base-control.coffee"
{ filter, each } = require "./utilities.coffee"

class SelectControl extends BaseControl

  value : ->
    sel = @selected()
    return unless sel.length
    if sel.length > 1
      return sel.map ( option ) -> option.value
    else
      return sel[0].value

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