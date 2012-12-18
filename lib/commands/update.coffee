###
Module dependencies
###
shell   = require "shelljs/global"
cp      = require "child_process"

###
Variables
###
tmp_path = "./.meteor/tmp"

###
Help
###
exports.help = [
  " update ".cmd + "<appname>".arg + "                                              Bundle and update the application bits"
  " update ".cmd + "<appname>".arg + " -b".opt + ", " + "--bundler ".opt + "<meteor, meteorite>            Set the bundler to use, default is auto-detect"
  " update ".cmd + "<appname>".arg + " -m".opt + ", " + "--mongodb ".opt + "<appfog, mongohq, mongolab>    Set the mongodb service to use, default is appfog service"
].join("\n")

###
Usage
###
exports.usage = [
  " -b, --bundler BUNDLER"
  " -m, --mongodb MONGODB"
]

exports.usage = [
  "Update the application bits"

  "Usage: meteor-af update [options] <appname>"
  "  -f, --force BUNDLER    Force to use the specify bundler (meteor or meteorite)"
  "  -m, --mongodb TYPE      Type of mongoDB to use (AppFog service, MongoHQ or MongoLab)"
]

###
Run
###
exports.run = (options) ->
  # Check if meteor can be found
  if not which "af"
    console.log "Error: Can not found af".error
    console.log "See " + "https://docs.appfog.com/getting-started/af-cli".info + " for help"
    process.exit 1


  # Check if an appname is present
  if options.argv[0]
    appname = options.argv[0]
    options.argv[0] = undefined # when invoke bundle command, default filename is set
  else
    console.log "Error: you must provide an appname".error
    apps_cmd = exec "af apps"
    process.exit 1

  # Call bundle command
  options.deploy = true
  require("./bundle").run(options)

  # If bundle to update exists
  if test('-d', tmp_path + "/bundle")
    dir = tmp_path + "/bundle"
  else
    console.log "Error: Can not find the bundle in ".red + tmp_path.red
    process.exit 1

  af_cmd = cp.spawn("af", ["update", appname],
    stdio: "inherit"
    cwd: dir
  )
  #af_cmd.stdout.on "data", (data) ->
  #  console.log "ERRRRROR: ".data

  af_cmd.on "exit", (code) ->
    # Remove tmp directory if exists
    if test('-d', tmp_path)
      rm "-rf", tmp_path

    unless code is 0
      console.log "ERROR: Can not update ".error + appname.red
      process.exit 1
    else
      process.stdout.write "Stats for " + appname.verbose
      setTimeout () ->
        stats_cmd = cp.spawn("af", ["stats", appname],
          stdio: "inherit"
        )
        stats_cmd.on "exit", (code) ->
          unless code is 0
            console.log "ERROR: Can not get stats for ".error + appname.error 
            process.exit 1
      , 5000  # Hack to get time to fetch the stats

  
  

  

  







  