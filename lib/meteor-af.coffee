###
Module dependencies
###
colors  = require("colors")
fs      = require "fs"


###
Colors
###
colors.setTheme
  verbose: 'cyan',
  info: 'green',
  help: 'cyan',
  warn: 'yellow',
  error: 'red',
  cmd: 'green',
  opt: 'cyan',
  arg: 'yellow'

###
Start application
###
meteorAf = module.exports =

  run: () ->
    try
      version = JSON.parse(fs.readFileSync(__dirname + "/../package.json")).version
    catch e
      console.log "Error: Can not find the version in ./package.json\n".error + e.toString().error + "\n"
      process.exit 1

    commands = [
      " update"
      " bundle"
    ]

    options = require('dreamopt') commands
    ,{
      help: (txt) -> 

        txt = [
          ""
          "Meteor-af is a tool for deploying your meteor application to AppFog.com"
          "Version ".grey + version.grey 
          ""
          "Usage: meteor-af " + "command".cmd + " [" + "<args>".arg + "] " + "[" + "options".opt + "] "
          ""
          "Currently available commands are:"
          ""
        ]

        commands.forEach (value, index)->
          cmd = value.replace(/\s/g,"")
          txt.push require("./commands/#{cmd}").help + "\n"

        txt.push [
          ""
          "Help"
          " -h".opt + ", " +"--help".opt + "                                                    Display this usage information"
        ].join("\n") + "\n"

        console.log txt.join("\n")
        process.exit 0

      loadCommandSyntax: (command) -> require("./commands/#{command}").usage
    }


    require("./commands/#{options.command}").run(options)

