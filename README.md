SteamLUG is continuing work on Haunt from 7dfps 2013 for the 2014 event!

First things first: port from Source SDK 2013 to Godot Engine.

Here are some design documents:
https://github.com/SteamLUG/steamlug-7dfps-2013/wiki

And the repo containing source files for all the assets:
https://github.com/SteamLUG/steamlug-7dfps-2014-asset-sources


# General issues

* Shadow casting seems not to be working very well for spotlights
https://github.com/okamstudio/godot/wiki/tutorial_shadow_mapping

# Lantern

* Raycasts should be tested when we have a (somehow) real scenario.
* We can change raycasts' orientation and position according to our needs.
* To add more raycasts, just do it on the player.xscn scene. Then
change the lantern script to add them in \_ready() with append\_rc()
function.

# Shaders
## Ghost


The ghost will have a shader that changes rendering for it, depending
on light influence, like **distance** or **number** of raycasts hit. If no
light affects, the ghost will be invisible for players.

Relevant docs:

* https://github.com/okamstudio/godot/wiki/tutorial_materials
* https://github.com/okamstudio/godot/wiki/tutorial_fixed_materials
* https://github.com/okamstudio/godot/wiki/tutorial_shader_materials
* https://github.com/okamstudio/godot/wiki/shader

*(assigned to raz)*

## Post-effects

Relevant docs:

* https://github.com/okamstudio/godot/wiki/tutorial_viewports
* https://github.com/okamstudio/godot/wiki/tutorial_multires
* https://github.com/okamstudio/godot/wiki/tutorial_canvas_layers
* Check *2D in 3D* demo.

*(assigned to raz)*

# Networking

Maybe use peer in server to receive sync data (ie. positions) from client peers,
so an initial approach for server on each frame could be something like this:

* Foreach peer, receive all sync data needed and push that data to a buffer
* Broadcast that buffer to all peer clients

On client side, it could be something in the mood of:

* Send my sync data to the server
* Receive all sync data from all entities, now we have two options
* Render entities from received sync data

Some questions arise

* Will movement be computed on each client?
* Will colision be computed on each client?
* Will players collide between them?
* Will players collide with the monster?

## Relevant classes

### TCP\_Server
* Start listening for incoming connections (*listen*)
* Stop listening whenever you want (*stop*)
* Accepts connections and returns StreamPeerTCP on taking a connection (*is_connection_available*, *take_connection*)

### StreamPeerTCP
* Connects to a server (*connect*)
* Sends and receive data across the network (*[put|get]_(partial_)?data* from **StreamPeer** inheritance)


## Asset credits
* Ghost model 
   * Alien Parasite used under [CC-BY-3.0](http://creativecommons.org/licenses/by/3.0/) - created by [Rock 76222](http://www.blendswap.com/user/Rock76222)
