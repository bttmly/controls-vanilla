BaseControl = require "./base-control.coffee"

class CheckableControl extends BaseControl

  value : ( param ) ->
    if param
      @el.value = param
      @
    else
      return if @el.checked then @el.value else false

module.exports = CheckableControl