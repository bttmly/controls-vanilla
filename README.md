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
Figuring out how to structure the values returned from a collection is tricky, which is why ControlCollection.prototype.value returns instances of ValueObject. These have handy methods for transforming the value array, and you can add to these through the prototype, which is exposed as `Controls.valueInit.prototype`.

### .normal()

### .valueArray()

### .idArray()

### .idValuePair

### .valueString( delimiter )
delimiter - *String*; defaults to `, `

### .valueArrayOne()

### .idArrayOne()

### .at( index )
index - *Number*

### .first()

### .last()

### .serialize()


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