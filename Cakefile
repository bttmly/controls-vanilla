exec = require( "child_process" ).exec
uglify = require( "uglify-js" )
browserify = require( "browserify" )
watchify = require( "watchify" )

task "build", "Build project.", ->
  exec "browserify -t coffeeify -o controls.js src/controls.coffee", ( err, stdout, stderr ) ->
    throw err if err
    exec "uglifyjs -o controls.min.js controls.js", ( err, stdout, stderr ) ->
      throw err if err
    return
  return

task "watch", "Watch project for changes", ->
  exec "watchify -t coffeeify -o controls.js src/controls.coffee", ( err, stdout, stderr ) ->
    throw err if err
    # time = ( new Date() ).toString().split( " " )[4]
