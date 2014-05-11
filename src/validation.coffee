validations = 

  notEmpty : ->
    ( str ) -> !!str

  notEmptyTrim : ->
    ( str ) -> !!str.trim()

  numeric : ->
    ( str ) ->
      /^\d+$/.test str

  alphanumeric : ->
    ( str ) ->
      /^[a-z0-9]+$/i.test str

  letters : ->
    ( str ) -> 
      /^[a-z]+$/i.test str

  isValue : ( value ) ->
    ( str ) ->
      str is value

  email : do ->
    i = document.createElement "input"
    i.type = "email"
    ->
      ( str ) ->
        i.value = str
        i.validity.valid

  allowed : ( allowedChars ) ->
    allowedChars = allowedChars.split( "" )
    ( str ) ->
      str = str.split( "" )
      for char in str
        return false if char not in allowedChars
      return true

  notAllowed : ( notAllowedChars ) ->
    notAllowedChars = notAllowedChars.split( "" )
    ( str ) ->
      str = str.split( "" )
      for char in notAllowedChars
        return false if char in notAllowedChars
      return true

  numberBetween : ( min, max ) ->
    ( str ) ->
      min <= Number( str ) <= max

  numberMax : ( max ) ->
    validations.between( 0, max )

  numberMin : ( min) ->
    validations.between( min, Number.POSITIVE_INFINITY )

  lengthBetween : ( min, max ) ->
    ( str ) ->
      min <= str.length <= max

  lengthMax : ( max ) ->
    validations.lengthBetween( 0, max )

  lengthMin : ( min ) ->
    validations.lengthBetween( min, Number.POSITIVE_INFINITY )




module.exports = validations