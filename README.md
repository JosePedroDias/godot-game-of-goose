# game of goose

## credits

- wood texture - https://www.flickr.com/photos/hirespic/36191787146/in/dateposted/


## TODO

- create new server opcode SLEEP(ms), use it between the two piece_moved opcodes on GO cells
- create new server opcode PLAYER_WON(user_id).
	- identify when a player lands on the winning cell
	- trigger a feedback opcode to say it too
	- trigger PLAYER_WON and state state.playing to false
- UI overlay with colored pieces and player names, highlight with arrow or alpha which player is playing now

- nice to have: UI roll die button
- nice to have: UI label to provide feedback to the players
- TODO: new client -> server opcode to request the server to print out its internal state
- WIP: resume nakama client after disconnect
- nice to have: particle effects during piece movement
- nice to have: add sound effects?
