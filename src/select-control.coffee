BaseControl = require "./base-control.coffee"
utilities = require "./utilities.coffee"
filter = utilities.filter

class SelectControl extends BaseControl

  value : ->
    sel = @selected()
    return unless sel.length
    if sel.length > 1
      return sel.map ( opt ) -> opt.value
    else
      return sel[0].value

  selected : ->
    filter @el.options, ( opt ) ->
      opt.selected and not opt.disabled

  valid : ->
    !!@value().length

module.exports = SelectControl