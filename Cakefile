{ spawn, exec } = require( "child_process" )
uglify = require( "uglify-js" )
browserify = require( "browserify" )
watchify = require( "watchify" )
coffeeify = require( "coffeeify" )
fs = require( "fs" )

task "build", "Build project.", ->
  b = browserify [ "./src/controls.coffee" ]
  b.transform "coffeeify"
  b.bundle ( err, src ) ->
    throw err if err
    fs.writeFile "./controls.js", src, ( err ) ->
      throw err if err
      fs.writeFile "controls.min.js", uglify.minify( "./controls.js" ).code, ( err ) ->
        throw err if err
        console.log "Build complete."

# Not working for now; process doesn't keep running.
#
# task "watch", "Watch project for changes", ->
#   w = watchify [ "./src/controls.coffee" ]
#   w.transform "coffeeify"
#   console.log w
#   w.on "update", ->
#     w.bundle ( err, src ) ->
#       throw err if err
#       fs.writeFile "controls.js", src, ( err ) ->
#         throw err if err
#         console.log "Watch build at #{ ( new Date() ).toString().split( " " )[4] }"

# Use exec in the meantime.
#
task "watch", "Watch project for changes", ->
  coffee = exec "watchify src/controls.coffee -t coffeeify -o controls.js -v"
  coffee.stdout.on "data", ( data ) -> console.log data.toString().trim()
  coffee.stderr.on "data", ( data ) -> console.log data.toString().trim()
