SteamLUG is continuing work on Haunt from 7dfps 2013 for the 2014 event!

First things first: port from Source SDK 2013 to Godot Engine.

Here are some design documents:
https://github.com/SteamLUG/steamlug-7dfps-2013/wiki

And the repo containing source files for all the assets:
https://github.com/SteamLUG/steamlug-7dfps-2014-asset-sources


Issues
======

* Shadow casting seems not to be working very well for spotlights
https://github.com/okamstudio/godot/wiki/tutorial_shadow_mapping


**Networking Doc**

TCP\_Server:
	+ listen for incoming cxs
	+ accepts cxs and return StreamPeerTCP on taking a cx

StreamPeerTCP:
	+ inherits from StreamPeer that has [put|get]_(partial_)?data
	+ connects to a server



