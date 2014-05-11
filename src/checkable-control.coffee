BaseControl = require "./base-control.coffee"

class CheckableControl extends BaseControl

  value: ( param ) ->
    if param
      @el.value = param
      @
    else
      return if @el.checked then @el.value else false

  checked: ( param ) ->
    initial = @el.checked
    if param? and param isnt initial
      @el.checked = param
      @dispatchEvent "change"
    @el.checked

  clear: ->
    if @checked()
      @checked( false )

module.exports = CheckableControl