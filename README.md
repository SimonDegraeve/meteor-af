# meteor-af

Deploy your [meteor](http://meteor.com/) application to [AppFog](http://www.appfog.com).

## Installation

```
npm install meteor-af 
```

## AF command line tool

**meteor-af** use the [command line tool](https://github.com/appfog/af) provide by AppFog. It uses the "update" command to deploy the application, let me know if you are interrested by using the "push" command (or anything else).
You also need to go to **Add-ons** and install either MongoLab or MongoHQ. After you have done so, go to **Env Variables** and add **MONGO_URL** variable specified by MongoLab or MongoHQ.

```
Example:

Name               Value
MONGO_URL          mongodb://appfog:<password>@linus.mongohq.com:10094/<database>
```

## Usage

Launch **meteor-af** in your meteor project directory.
```
  meteor-af deploy MyApp             # where 'MyApp' is your AppFog application
  meteor-af -mrt deploy MyAPP        # if you want to use meteorite instead of meteor   
```

## Compatibilities

Testing with Meteor 0.5.0 and Ubuntu 12.10.

