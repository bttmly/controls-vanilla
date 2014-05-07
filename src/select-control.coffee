BaseControl = require "./base-control.coffee"
utilities = require "./utilities.coffee"
filter = utilities.filter

class SelectControl extends BaseControl
  value : ->
    results = []
    for option in this.selected()
      if option.value then results.push( option.value )
    return results

  selected : ->
    filter this.el.querySelectorAll( "option" ), ( opt ) ->
      return opt.selected and opt.value and not opt.disabled

module.exports = SelectControl