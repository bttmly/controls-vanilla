# numbers = "01234567890"
# lLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
# uLetters = "abcdefghijklmnopqrstuvwxyz"

controlValidations = 

  notEmpty : ->
    -> !!@el.value

  notEmptyTrim : ->
    -> !!@el.value.trim()

  numeric : ->
    ->
      /^\d+$/.test @el.value

  alphanumeric : ->
    ->
      /^[a-z0-9]+$/i.test @el.value

  letters : ->
    -> 
      /^[a-z]+$/i.test @el.value

  isValue : ( value ) ->
    ->
      @el.value is value

  phone : ->
    controlValidations.allowed( "1234567890()-+" )

  email : ->
    i = document.createElement( "input" )
    i.type = "email"
    ->
      i.value = @el.value
      !!@el.value and i.validity.valid

  datalist : ->
    ->
      listValues = map ( @el.list or [] ), ( option ) ->
        option.value
      @el.value in listValues

  allowed : ( allowedChars ) ->
    allowedChars = allowedChars.split( "" )
    ->
      str = @el.value.split( "" )
      for char in str
        return false if char not in allowedChars
      return true

  notAllowed : ( notAllowedChars ) ->
    notAllowedChars = notAllowedChars.split( "" )
    ->
      str = @el.value.split( "" )
      for char in notAllowedChars
        return false if char in notAllowedChars
      return true

  numberBetween : ( min, max ) ->
    ->
      min <= Number( @el.value ) <= max

  numberMax : ( max ) ->
    controlValidations.between( 0, max )

  numberMin : ( min) ->
    controlValidations.between( min, Number.POSITIVE_INFINITY )

  lengthBetween : ( min, max ) ->
    ->
      min <= @el.value.length <= max

  lengthMax : ( max ) ->
    controlValidations.lengthBetween( 0, max )

  lengthMin : ( min ) ->
    controlValidations.lengthBetween( min, Number.POSITIVE_INFINITY )

  lengthIs : ( len ) ->
    ->
      @el.value.length is len


collectionValidations =

  allValid: ->
    @every ( control ) -> control.valid()

  anyValid: ->
    @some ( control ) -> control.valid()

  allChecked: ->
    @every ( control ) -> control.checked()

  anyChecked: ->
    @some ( control ) -> control.checked()

  allHaveSelected: ->
    @every ( control ) -> control.selected().legnth

  anyHaveSelected: ->
    @some ( control ) -> control.selected().length



module.exports = {
  controlValidations: controlValidations
  collectionValidations: collectionValidations
}
