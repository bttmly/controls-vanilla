exec = require( "child_process" ).exec
uglify = require( "uglify-js" )
browserify = require( "browserify" )

task "build", "Build project.", ->
  exec "browserify -t coffeeify src/controls.coffee > controls.js", ( err, stdout, stderr ) ->
    throw err if err
    exec "uglifyjs -o controls.min.js controls.js", ( err, stdout, stderr ) ->
      throw err if err
    return
  return