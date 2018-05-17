Minetest mission mod (missions)
======

Minetest mod for in-game mission creation
Adds some blocks to create missions with rewards, timeout and penalties

# Install

* Unzip/Clone it to your worldmods folder

# Blocks

## Mission-chest (missions:chest)

# Mission-types

## Transport (missions:transport)

## Other missions

The other mission types are not implemented yet, but many can be emulated by the transport mission:
* Walk (missions:walk)
* Kill (missions:kill)
* Goto (missions:goto)
* Dig (missions:dig)
* Craft (missions:craft)

# Depends

* default
* xp_redo?

# Screenshots

## Mission-blocks (chest and mission-types)
![](screenshots/Minetest_2018-05-17-09-18-20.png?raw=true)
Note: **Android screenshot**

## Mission chest with book as reference
![](screenshots/Minetest_2018-05-17-09-18-38.png?raw=true)

## Example transport mission configuration
![](screenshots/Minetest_2018-05-17-09-18-49.png?raw=true)

# Pull requests / bugs

I'm happy for any bug reports or pull requests (code and textures)

# TODO / Ideas

* Implement more mission-types
* Persist missions across server-restart (player:set_attribute)
* HUD improvements