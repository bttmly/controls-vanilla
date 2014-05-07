util = require "./utilities.coffee"

validations = 

  email : do ->
    i = document.createElement "input"
    i.type = "email"
    ->
      i.value = @el.value
      i.validity.valid

  numeric : ( el ) ->
    /^\d+$/.test el.value

  alphanumeric : ( el ) ->
    /^[a-z0-9]+$/i.test el.value

  letters : ( el ) ->
    /^[a-z]+$/i.test el.value

  allowed : ( allowedChars ) ->
    allowedChars = allowedChars.split()
    ->
      str = @el.value.split()
      for char in str
        return false if char not in allowedChars
      return true

  notAllowed : ( notAllowedChars ) ->
    notAllowedChars = notAllowedChars.split()
    ->
      str = @el.value.split()
      for char in notAllowedChars
        return false if char in notAllowedChars
      return true



module.exports = validations