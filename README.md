bicrophonic1
============

Platform to play audio attached geographical locations and the movements of a bike http://sonicbikes.net

Map control
-----------------
A JSON file controls how and where sounds are played. The paramterers are:

- Sound filename
- Direction parameter: (Multiple select for NE etc.) 
  - North (Sample is played when moving north) 
  - South (Sample is played when moving south) 
  - East (Sample is played when moving east)
  - West (Sample is played when moving west)
- Pan Paramter: 
  - North (If cycling north and you want sound out of Left speaker set to west)
  - South (If cycling south and you want sound out of Left speaker set to east)
  - East (If cycling east and you want sound out of Left speaker set to north)
  - West (If cycling west and you want sound out of Left speaker set to south)
- Sample parameters: 
  - Loop (Sound file will loop on entering a zone and stop on leaving)
  - Ghost (two polygons are drawn and the zone oscillates between them)
  - One shot (Sample will play to the end whatever happens)
