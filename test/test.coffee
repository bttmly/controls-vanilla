slice = Function::call.bind( Array::slice )
qs = document.querySelector.bind( document )
gebi = document.getElementById.bind( document )

gebn = ( name ) ->
  slice document.getElementsByName( name )

qsa = ( selector, context = document ) ->
  context = document.querySelector( context ) if typeof context is "string"
  slice context.querySelectorAll( selector )

inc = -> 
  i = 0
  -> ++i

test "Value Object", ->
  mixedControls = Controls( "#mixed-controls" )
  check = qs( "#mixed-controls [type='checkbox']" )
  text = qs( "#mixed-controls [type='text']" )
  select = qs( "#mixed-controls select" )

  check.checked = true
  text.value = "text"

  values = mixedControls.value()

  equal JSON.stringify( values.normal() ), 
    JSON.stringify [
      { id: "mixedCheck", value: "check" }, 
      { id: "mixedText", value: "text" }, 
      { id: "mixedSelect", value: "option3"}
    ]
  , ".normal() looks good, and .serialize() by extension"

  equal JSON.stringify( values.valueArray() ),
    JSON.stringify( ["check", "text", "option3"] ),
    ".valueArray() looks good"

  equal JSON.stringify( values.idArray() ),
    JSON.stringify( ["mixedCheck", "mixedText", "mixedSelect"] ),
    ".idArray() looks good"

  equal JSON.stringify( values.idValuePair() ),
    JSON.stringify( {"mixedCheck": "check", "mixedText": "text", "mixedSelect": "option3"} ),
    ".idValuePair() looks good"

  equal values.valueString(), "check, text, option3", ".valueString() default looks good"
  equal values.valueString("---"), "check---text---option3", "valueString() with custom delimiter looks good"

  equal values.at( 1 ), "text", ".at() looks good called with number"
  equal values.at( "mixedText" ), "text", ".at() looks good called with a string"
  equal values.first(), "check", ".first() looks good"
  equal values.last(), "option3", ".last() looks good"

  equal JSON.stringify( values.valueArrayOne() ), JSON.stringify( values.valueArray() ), ".idArrayOne() with length > 1 looks good"
  equal JSON.stringify( values.idArrayOne() ), JSON.stringify( values.idArray() ), ".idArrayOne() with length > 1 looks good"

  check.checked = false
  text.value = ""

  equal mixedControls.value().valueArrayOne(), "option3", ".valueArrayOne() with length === 1 looks good"
  equal mixedControls.value().idArrayOne(), "mixedSelect", ".idArrayOne() with length === 1 looks good"
  
  # more stuff
  equal mixedControls.filter("input").value().valueArrayOne(), undefined, ".valueArrayOne with length === 0 looks good"
  equal mixedControls.filter("input").value().idArrayOne(), undefined, ".idArrayOne() with length === 0 looks good"

test "Valid", ->
  notEmpty = gebi "notEmpty"
  notEmptyTrim = gebi "notEmptyTrim"
  numeric = gebi "numeric"
  alphanumeric = gebi "alphanumeric"
  letters = gebi "letters"
  isValue = gebi "isValue"
  phone = gebi "phone"
  email = gebi "email"
  list = gebi "list"
  allowed = gebi "allowed"
  notAllowed = gebi "notAllowed"
  numberBetween = gebi "numberBetween"
  numberMax = gebi "numberMax"
  numberMin = gebi "numberMin"
  lengthBetween = gebi "lengthBetween"
  lengthMax = gebi "lengthMax"
  lengthMin = gebi "lengthMin"
  lengthIs = gebi "lengthIs"

  equal Controls.validate( notEmpty ), true, "'notEmpty' validation true as expected"
  equal Controls.validate( notEmptyTrim ), true, "'notEmptyTrim' validation true as expected"
  equal Controls.validate( numeric ), true, "'numeric' validation true as expected"
  equal Controls.validate( alphanumeric ), true, "'alphanumeric' validation true as expected"
  equal Controls.validate( letters ), true, "'letters' validation true as expected"
  equal Controls.validate( isValue ), true, "'isValue' validation true as expected"
  equal Controls.validate( phone ), true, "'phone' validation true as expected"
  equal Controls.validate( email ), true, "'email' validation true as expected"
  equal Controls.validate( list ), true, "'list' validiation true as expected"
  equal Controls.validate( allowed ), true, "'allowed' validation true as expected"
  equal Controls.validate( notAllowed ), true, "'notAllowed' validation true as expected"
  equal Controls.validate( numberBetween ), true, "'numberBetween' validation true as expected"
  equal Controls.validate( numberMax ), true, "'numberMax' validation true as expected"
  equal Controls.validate( numberMin ), true, "'numberMin' validation true as expected"
  equal Controls.validate( lengthBetween ), true, "'lengthBetween' validation true as expected"
  equal Controls.validate( lengthMax ), true, "'lengthMax' validation true as expected"
  equal Controls.validate( lengthMin ), true, "'lengthMin' validation true as expected"
  equal Controls.validate( lengthIs ), true, "'lengthIs' validation true as expected"

  notEmptyFalse = gebi "notEmptyFalse"
  notEmptyTrimFalse = gebi "notEmptyTrimFalse"
  numericFalse = gebi "numericFalse"
  alphanumericFalse = gebi "alphanumericFalse"
  lettersFalse = gebi "lettersFalse"
  isValueFalse = gebi "isValueFalse"
  phoneFalse = gebi "phoneFalse"
  emailFalse = gebi "emailFalse"
  listFalse = gebi "listFalse"
  allowedFalse = gebi "allowedFalse"
  notAllowedFalse = gebi "notAllowedFalse"
  numberBetweenFalse = gebi "numberBetweenFalse"
  numberMaxFalse = gebi "numberMaxFalse"
  numberMinFalse = gebi "numberMinFalse"
  lengthBetweenFalse = gebi "lengthBetweenFalse"
  lengthMaxFalse = gebi "lengthMaxFalse"
  lengthMinFalse = gebi "lengthMinFalse"
  lengthIsFalse = gebi "lengthIsFalse"

  equal Controls.validate( notEmptyFalse ), false, "'notEmpty' validation false as expected" 
  equal Controls.validate( notEmptyTrimFalse ), false, "'notEmptyTrim' validation false as expected" 
  equal Controls.validate( numericFalse ), false, "'numeric' validation false as expected" 
  equal Controls.validate( alphanumericFalse ), false, "'alphanumeric' validation false as expected" 
  equal Controls.validate( lettersFalse ), false, "'letters' validation false as expected" 
  equal Controls.validate( isValueFalse ), false, "'isValue' validation false as expected" 
  equal Controls.validate( phoneFalse ), false, "'phone' validation false as expected" 
  equal Controls.validate( emailFalse ), false, "'email' validation false as expected" 
  equal Controls.validate( listFalse ), false, "'list' validation false as expected" 
  equal Controls.validate( allowedFalse ), false, "'allowed' validation false as expected" 
  equal Controls.validate( notAllowedFalse ), false, "'notAllowed' validation false as expected" 
  equal Controls.validate( numberBetweenFalse ), false, "'numberBetween' validation false as expected" 
  equal Controls.validate( numberMaxFalse ), false, "'numberMax' validation false as expected" 
  equal Controls.validate( numberMinFalse ), false, "'numberMin' validation false as expected" 
  equal Controls.validate( lengthBetweenFalse ), false, "'lengthBetween' validation false as expected" 
  equal Controls.validate( lengthMaxFalse ), false, "'lengthMax' validation false as expected" 
  equal Controls.validate( lengthMinFalse ), false, "'lengthMin' validation false as expected" 
  equal Controls.validate( lengthIsFalse ), false, "'lengthIs' validation false as expected" 

  radios = gebn "radio"
  equal Controls.validate( radios[0] ), false, "Radio should not validate if none matching it's name are checked"
  radios[0].checked = true
  equal Controls.validate( radios[0] ), true, "Radio should validate if it itself is checked"
  equal Controls.validate( radios[1] ), true, "Radio should validate if another radio matching it's name is checked"

  checks = gebn "checkbox"
  equal Controls.validate( checks[0] ), true, "Checkbox should by default validate if none matching it's name are checked"
  equal Controls.validate( checks[1] ), false, "Checkbox should not validate if <= 'min' matching it's name are checked"
  checks[0].checked = true
  equal Controls.validate( checks[1] ), true, "Checkbox should validate if >= 'min' matching it's name are checked"
  equal Controls.validate( checks[2] ), true, "Checkbox should validate if <= 'max' matching it's name are checked"
  checks[1].checked = true
  equal Controls.validate( checks[2] ), false, "Checkbox should not validate if >= 'max' matching it's name are checked"

  composed = gebi "composed1"
  equal Controls.validate( composed ), false, "Composed validation should fail if none match"
  composed.value = 1234567890
  equal Controls.validate( composed ), false, "Composed validation should fail if any don't match"
  composed.value = 123456
  equal Controls.validate( composed ), true, "Composed validation should succeed only if all match"


test "Filtering", ->
  mixedControls = Controls( "#mixed-controls" )
  check = qs( "#mixed-controls [type='checkbox']" )
  select = qs( "#mixed-controls select" )


  noCheck = mixedControls.not( "[type='checkbox']" )
  noSelect = mixedControls.not ( control ) ->
    control.tagName.toLowerCase() is "select"

  equal( noCheck.length, 2, ".not() rejects controls by selector." )
  equal( check not in noCheck, true, "Rejected item removed by selector.")
  equal( noSelect.length, 2, ".not() rejects controls by test function." )
  equal( select not in noSelect, true, "Rejected item removed by test function." )
  

  justCheck = mixedControls.filter( "[type='checkbox']" )
  justSelect = mixedControls.filter ( control ) ->
    control.tagName.toLowerCase() is "select"

  equal( justCheck.length, 1, ".filter() keeps controls by selector." )
  equal( justCheck[0], check, "Kept control by selector" )
  equal( justSelect.length, 1, ".filter() keeps controls by test function." )
  equal( justSelect[0], select, "Kept control by test function." )

  tagInput = mixedControls.tag( "input" )
  equal ( tagInput.every ( e ) -> e.tagName.toLowerCase() is "input") , true, ".tag() filters controls by tag"

  typeText = mixedControls.type( "text" )
  equal ( typeText.every ( e ) -> e.type.toLowerCase() is "text" ), true, ".type() filters controls by type"


test "Clear", ->
  mixedControls = Controls( "#mixed-controls" )
  check = qs( "#mixed-controls [type='checkbox']" )
  text = qs( "#mixed-controls [type='text']" )
  select = qs( "#mixed-controls select" )

  check.checked = true
  text.value = "text value"
  select[2].selected = true

  equal( check.checked, true, "Checkbox starts checked." )
  equal( text.value, "text value", "Text input starts with value." )
  equal( select.selectedIndex, 2, "Select starts with third option selected" )

  mixedControls.clear()

  equal( check.checked, false, "Checkbox unchecked after clear." )
  equal( text.value, "", "Text input value is '' after clear." )
  equal( select.selectedIndex, 0, "First select option selected after clear." )

test "Property setting", ->
  mixedControls = Controls( "#mixed-controls" )
  check = qs( "#mixed-controls [type='checkbox']" )
  text = qs( "#mixed-controls [type='text']" )
  select = qs( "#mixed-controls select" )

  equal ( mixedControls.every ( c ) -> !c.disabled ), true, "All controls initially not disabled"
  mixedControls.disabled( true )
  equal ( mixedControls.every ( c ) -> c.disabled ), true, "All controls disabled after .disabled( true )"
  mixedControls.disabled( false )
  equal ( mixedControls.every ( c ) -> !c.disabled ), true, "All controls enabled again after .disabled( false )"

  equal ( mixedControls.every ( c ) -> !c.required ), true, "All controls initially not required"
  mixedControls.required( true )
  equal ( mixedControls.every ( c ) -> c.required ), true, "All controls required after .required( true )"
  mixedControls.required( false )
  equal ( mixedControls.every ( c ) -> !c.required ), true, "All controls not required again after .required( false )"

  timesChanged = 0
  mixedControls.on "change", ( evt )->
    console.log evt.target
    ++timesChanged

  equal ( check.checked ), false, "Checkbox initially unchecked"
  mixedControls.checked( true )
  mixedControls.checked( true )  
  equal ( check.checked ), true, "Checkbox checked after .checked( true )"
  equal timesChanged, 1, "Using .checked( true ) triggers a change event only if checked changes"
  equal ( "checked" in text ), false, "No 'checked' property added to other types of inputs."
  mixedControls.checked( false )
  mixedControls.checked( false )
  equal ( check.checked ), false, "Checkbox again unchecked after .checked( false )"
  equal timesChanged, 2, "Using checked( false ) triggers a change event only if checked changes"

test "Events", ->
  mixedControls = Controls( "#mixed-controls" )
  text = qs( "#mixed-controls [type='text']" )

  changeHeard = false
  correctContext = false
  handler = mixedControls.on "change", ( event ) ->
    changeHeard = !changeHeard
    correctContext = true if @ is mixedControls
  mixedControls[0].dispatchEvent new Event "change", bubbles: true
  equal changeHeard, true, ".on() attaches event listener"
  equal correctContext, true, "Handler bound to control collection"

  mixedControls.off( "change", handler )
  mixedControls[0].dispatchEvent new Event "change", bubbles: true
  equal changeHeard, true, ".off() removes event listener"

  clicks = inc()
  v = undefined
  mixedControls.on "click", ( event ) ->
    v = clicks()
  mixedControls.trigger( "click" )
  equal v, 1, ".trigger() works for event triggering"

  equal mixedControls._eventListeners.click.length, 1, "_eventListeners holds references to listeners"

  mixedControls.offAll( "click" )
  mixedControls.trigger( "click" )
  equal v, 1, ".offAll() removes events"

  textCtl = mixedControls.filter( "[type='text']" )
  textCtl.valid = -> true
  validHeard = false
  textCtl.on "valid", ( event ) ->
    validHeard = true
  textCtl.trigger( "change" )
  equal validHeard, true, "automatic 'valid' event triggering working"



test "Misc.", ->

  text1 = Controls( "#text1" )
  clickHeard = false
  text1.on "click", ( event ) ->
    clickHeard = true
  text1.invoke( "click" )
  equal clickHeard, true, "Invoking 'click' triggers listeners"

  mixedControls = Controls( "#mixed-controls" )
  response = []
  mixedControls.invoke ->
    response.push( "invoked" )
  equal JSON.stringify( response ), JSON.stringify( ["invoked", "invoked", "invoked"] ), "Passing functions to invoke works."

  response = []
  mixedControls.invoke ->
    response.push( @id )
  equal JSON.stringify( response ), JSON.stringify( ["mixedCheck", "mixedText", "mixedSelect"] ), "Functions are invoked in the context of the control DOM element."
  
  labels = qsa( "label", "#mixed-controls" )
  colLabels = mixedControls.labels()
  equal labels.length is colLabels.length and labels.every( ( label ) ->
    label in colLabels
  ), true, "Labels gets labels of collection's controls"

test "External", ->

  noop = ->

  a = Controls.getValidations()
  a.radio = noop
  b = Controls.getValidations()
  equal ( b.radio is noop ), false, "Can't modify controlValidations directly."

  c = Controls.getValidations()
  c.noop = noop
  d = Controls.getValidations()
  equal ( "noop" of d ), false, "Can't add controlValidations directly."

  Controls.addValidation "noop", noop
  e = Controls.getValidations()
  equal ( "noop" of e ), true, "Can add controlValidations through addValidation()"

  mixedControls = Controls( "#mixed-controls" )
  equal mixedControls.constructor, Controls.init, "ControlCollection constructor is exposed as Controls.init"
  equal Object.getPrototypeOf( mixedControls ), Controls.init.prototype, "ControlCollection prototype is exposed as Controls.init.prototype"
  equal mixedControls instanceof Controls.init, true, "instances of ControlCollection pass instanceof with Controls.init"
  Controls.init.prototype.newCollectionMethod = -> true
  equal mixedControls.newCollectionMethod(), true, "Methods added to Controls.init.prototype are avaialble to ControlCollection instances"

  vals = mixedControls.value()
  equal vals.constructor, Controls.valueInit, "ValueObject constructor is exposed as Controls.valueInit"
  equal Object.getPrototypeOf( vals ), Controls.valueInit.prototype, "ValueObject prototype exposed as Controls.valueInit.prototype."
  equal vals instanceof Controls.valueInit, true, "instances of ValueObject pass instanceof with Controls.valueInit"
  Controls.valueInit.prototype.newValueMethod = -> true
  equal vals.newValueMethod(), true, "Methods added to Controls.valueInit.prototype are avaialble to ControlCollection instances"