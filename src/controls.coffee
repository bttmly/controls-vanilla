( ( root, factory ) ->

  if typeof define is "function" and define.amd
    define [
      "exports"
    ], ( exports ) ->
      root.Controls = factory( root, exports )
      return  

  else if typeof exports isnt "undefined"
    factory( root, exports )

  else
    root.Controls = factory( root, {} )

  return

)( this, ( root, Controls ) ->
  Controls = require "./factory.coffee"
  return Controls
)