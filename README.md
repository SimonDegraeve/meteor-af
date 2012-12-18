# meteor-af

Deploy your [meteor](http://meteor.com/) application to [AppFog](http://www.appfog.com).
The tool is also compatible with [meteorite](https://atmosphere.meteor.com/wtf/app) and it can be used to deploy your application using different mongoDB service: appfog, mongoHQ and mongoLab.

## Installation

```
npm install meteor-af 
```
Or if you want to install globally
```
[sudo] npm install -g meteor-af 
```


## AF command line tool

**meteor-af** use the [command line tool](https://github.com/appfog/af) provide by AppFog, so you need to install it first.


## Usage

Launch **meteor-af** in your meteor project directory.
```
Usage: meteor-af command [<args>] [options] 
 update <appname>                                              Bundle and update the application bits
 update <appname> -b, --bundler <meteor, meteorite>            Set the bundler to use, default is auto-detect
 update <appname> -m, --mongodb <appfog, mongohq, mongolab>    Set the mongodb service to use, default is appfog service 
```

## Todo

Use "af push" to create a new app if it not exists.
Create and bind automatically the mongodb service from appfog it it not exists.

## Compatibilities

Testing with Meteor 0.5.0, appfog cammand line 0.3.18 and Ubuntu 12.10.

