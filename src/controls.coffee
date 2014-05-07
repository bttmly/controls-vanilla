( ( root, factory ) ->

  root = window
  root.Controls = factory( root, {} )

)( this, ( root, Controls ) ->
  Controls = require "./factory.coffee"
  return Controls
)