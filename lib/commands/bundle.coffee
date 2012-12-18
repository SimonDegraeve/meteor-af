###
Module dependencies
###
shell   = require "shelljs/global"
fs      = require "fs"

###
Variables
###
filename = "app.tgz"
tmp_path = "./.meteor/tmp"
file_to_edit_path = tmp_path + "/bundle/server/server.js"
search_str = "var port = process.env.PORT ? parseInt(process.env.PORT) : 80;"
hack_appfog = ["//var port = process.env.PORT ? parseInt(process.env.PORT) : 80;"
               "  "
               "  // Hack for AppFog"
               "  var port = process.env.VMC_APP_PORT ? parseInt(process.env.VMC_APP_PORT) : 1337;"
               "  var env = JSON.parse(process.env.VCAP_SERVICES);"
               "  if(!env['mongodb-1.8'])"
               "   throw new Error('Make sure AppFog MongoDB service is bind to your application.');"
               "  var mongo = env['mongodb-1.8'][0]['credentials'];"
               ""
               "  process.env.MONGO_URL = mongo.url;"].join("\n")
hack_mongohq = ["//var port = process.env.PORT ? parseInt(process.env.PORT) : 80;"
               "  "
               "  // Hack for AppFog"
               "  var port = process.env.VMC_APP_PORT ? parseInt(process.env.VMC_APP_PORT) : 1337;"
               "  if(!process.env.MONGOHQ_URL)"
               "   throw new Error('MONGOHQ_URL must be set in environment. Make sure MongoHQ add-on is installed.');"
               ""
               "  process.env.MONGO_URL = process.env.MONGOHQ_URL;"].join("\n")
hack_mongolab = ["//var port = process.env.PORT ? parseInt(process.env.PORT) : 80;"
               "  "
               "  // Hack for AppFog"
               "  var port = process.env.VMC_APP_PORT ? parseInt(process.env.VMC_APP_PORT) : 1337;"
               "  if(!process.env.MONGOLAB_URI)"
               "   throw new Error('MONGOLAB_URI must be set in environment. Make sure MongoLab add-on is installed.');"
               ""
               "  process.env.MONGO_URL = process.env.MONGOLAB_URI;"].join("\n")

###
Help
###
exports.help = [
  " bundle".cmd + " [" + "app.tgz".arg + "] " + "                                             Pack this project up into a tarball, default file is app.tgz"
  " bundle".cmd + " [" + "app.tgz".arg + "] " + "-b".opt + ", " + "--bundler ".opt + "<meteor, meteorite>            Set the bundler to use, default is auto-detect"
  " bundle".cmd + " [" + "app.tgz".arg + "] " + "-m".opt + ", " + "--mongodb ".opt + "<appfog, mongohq, mongolab>    Set the mongodb service to use, default is appfog service"
].join("\n")

###
Usage
###
exports.usage = [
  " -b, --bundler BUNDLER"
  " -m, --mongodb MONGODB"
]

###
Run
###
exports.run = (options) ->

  # Set the bundler
  if options.bundler
    switch options.bundler
      when "meteor"
        bundler = { "name": "meteor", "cmd": "meteor", "url_help": "https://atmosphere.meteor.com/wtf/app" }
      when "meteorite", "mrt"
        bundler = { "name": "meteorite", "cmd": "mrt", "url_help": "http://docs.meteor.com/" }
      else
        console.log "Error: ".error + options.force.error + " is not a correct bundler".error
        console.log "Run with --help for help"
        process.exit 1

  # Auto-detection
  else
    # Test if smart.json exists in directory = use the meteorite bundler
    if test('-f', "./smart.json")
      bundler = { "name": "meteorite", "cmd": "mrt", "url_help": "http://docs.meteor.com/" }
    else
      bundler = { "name": "meteor", "cmd": "meteor", "url_help": "https://atmosphere.meteor.com/wtf/app" }

  # Check if the bundler can be found
  if not which bundler.cmd
    console.log "Error: Can not found ".error + bundler.name.error
    console.log "See " + bundler.url_help.info + " for help"
    process.exit 1

  # Set mongodb service
  if options.mongodb
    switch options.mongodb
      when "appfog"
        mongo = { "name": "AppFog MongoDB service", "hack": hack_appfog }
      when "mongohq"
        mongo = { "name": "MongoHQ", "hack": hack_mongohq }
      when "mongolab"
        mongo = { "name": "MongoLab", "hack": hack_mongolab}
      else
        console.log "Error: ".error + options.mongodb.error + " is not a correct mongoDB service".error
        console.log "Run with --help for help"
        process.exit 1
  else
    mongo = { "name": "AppFog MongoDB service", "hack": hack_appfog }

  # Check if argument is present
  if options.argv[0]
    filename = options.argv[0]

  console.log "\nBundling " + filename.verbose + " with " + bundler.name.verbose + " and " + mongo.name.verbose

  # Build the tarball
  process.stdout.write "  Building: "
  bundle_cmd = exec bundler.cmd + " bundle " + filename, silent: true
  if options.meteorite
    output = bundle_cmd.output.replace(/((.|\n|\r)*)Here\ comes\ Meteor\!\n*\u001b\[39m\n\n/gi,"")
    if output
      console.log output.error
      process.exit 1
  else
    if bundle_cmd.code != 0
      console.log bundle_cmd.output.error
      # Test if smart.json exists in directory = you should use meteorite instead of meteor
      if test('-f', "./smart.json")
        console.log "File " + "smart.json".info + " found. You shoud try to use meteorite instead of meteor"
        console.log "Run with --help for help"
      process.exit 1
  console.log "OK".info

  # Extract the tarball and had the hack
  process.stdout.write "  Extracting and adding hack: "
  # Create tmp directory if not exists
  if not test('-d', tmp_path)
    mkdir "-p", tmp_path
  # Extract to the tmp directory  
  tar_cmd = exec "tar -C " + tmp_path + " -xf " + filename, silent: true
  # If error
  if tar_cmd.code != 0
    console.log tar_cmd.output.error
    process.exit 1
  else

    # If no error, had the hack
    try
      data = fs.readFileSync(file_to_edit_path, "utf8")
    catch e
      console.log e.toString().error
      process.exit 1
    try
      data = data.toString().replace(search_str, mongo.hack)
    catch e
      console.log e.toString().error
      process.exit 1
    try
      fs.writeFileSync file_to_edit_path, data, "utf8"
    catch e
      console.log e.toString().error
      process.exit 1
  console.log "OK".info

  # Rebuild the tarball
  process.stdout.write "  Rebuilding: "
  tar_cmd = exec "tar -C " + tmp_path + " -czf " + filename + " bundle ", silent: true
  if tar_cmd.code != 0
    console.log tar_cmd.output.error
    process.exit 1
  console.log "OK".info

  # If not invoked by update
  if not options.update
    # Remove tmp directory if exists
    if test('-d', tmp_path)
      rm "-rf", tmp_path

  console.log ""







  