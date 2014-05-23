# Controls
_A little library for dealing with user input controls._

## ControlCollection
ControlCollection is the library's primary class. It's a wrapper around a collection of DOM elements. Generally, you won't initialize ControlCollection instances directly. The global `Control` object the library creates is a factory function for producing control collections. `Control()` returns ControlCollection instances. The following methods are found in `ControlCollection.prototype`

### .value()

### .value()

### .filter( _String_ or _Function_ )

### .not( _String_ or _Function_ )

### .tag( _String_ )

### .type( _String_ )

### .clear()

### .disabled( _Boolean_ )
_Argument will be coerced to boolean._

### .required( _Boolean_ )
_Argument will be coerced to boolean._

### .checked( _Boolean_ )
_Argument will be coerced to boolean._

### .on( *eventName* _String_, *eventHandler* _Function_ )

### .off( *eventName* _String_, *eventHandler* _Function_ )

### .trigger( _String_ or _Event_ )

### .invoke( _String_ or _Function_, arguments... )

### .labels()

### .mapIdToProp( _String_ )

### .setValidityListener()


## ValueObject
ValueObjects represent property values of a collection. The .value(), .prop(), and .data() methods of ControlCollections return ValueObject instances when called with their "get" signatures.

### .normal()
Returns an vanilla array with the following structure:
```javascript
[ { id: "element1Id", value: "element1Value" }
  { id: "element2Id", value: "element2Value" } ]
```

### .valueArray()
Returns an array with the following structure:
```javascript
[ "element1Value", "element2Value" ]
```

### .idArray()
Returns an array with the following structure:
```javascript
[ "element1Id", "element2Id" ]
```

### .idValuePair
Returns an object with the following structure:
```javascript
{ element1Id: "element1Value",
  element2Id: "element2Value" }
```

### .valueString( delimiter )
Returns a string with values separated by `delimiter` (defaults to ", "). Equivalent to `.valueArray().join( delimiter )`.
```javascript
"element1Value, element2Value"
```

### .valueArrayOne()
Like .valueArray() but will return just array[0] if the array's length is 1.

### .idArrayOne()
Like .idArray() but will return just array[0] if the array's length is 1.

### .at( accessor )
.at() depends on whether you pass it a number of a string. If `isNaN( Number( accessor ) )` is true, `.at( accessor )` is equivalent to `.idValuePair()[ accessor ]`. Otherwise, it's equivalent to `.valueArray()[ accessor ]`. So pass a string to get the value of the element with the matching `id`, or pass a number to get an element's value by index in the collection.

### .first()
=== `.at( 1 )`

### .last()
=== `.at( this.length - 1 )

### .serialize()
=== JSON.serialize( this )

## Control Validation
Add these to controls with `data-control-validation` to activate them.

### notEmpty

### notEmptyTrim

### numeric

### alphanumeric

### letters

### isValue

### phone

### email

### list

### radio

### checkbox

### allowed

### notAllowed

### numberBetween

### numberMax

### numberMin

### lengthBetween

### lengthMax

### lengthMin

### lengthIs