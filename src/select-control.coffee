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
    filter this.el.children, ( opt ) ->
      return opt.tagName.toLowerCase() is "option" and opt.selected and opt.value and not opt.disabled


  valid : ->
    !!@value().length

module.exports = SelectControl