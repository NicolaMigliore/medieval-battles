# Features to Implement
- [ ] Attack order should be determined by a ne "initiative" stat
- [ ] Chars: Characters should be able to assign up to 3 charms that can grant special effects to their actions. Examples:
	- apply elemental damage to attack
	- apply bleeding to boosted character
	- chance to grant block at each turn
	- after action pick a random character and move to the end of the execution order
	- Necromancy: chance to add to the team a skeleton
	- Curse: invert the effect of moves, can target anyone and can be used to use a healer to do great damage or similar.
	Charms will be unlocked randomly adding some rouge-lite feeling and offering more build choice.
- [ ] Game should start with a warrior and a second character that the player can choose.
	The choice should be prompted by an NPC that asks to describe player and ally.

# TODOs:
- [x] On round configure order based on initiative
- [X] Implement boosting effects
- [X] Implement AI taking actions
- [X] Move characters forward when they are taking an action
- [X] Move characters during actions
- [X] Add progress bars for HP
- [X] Add action particles
- [X] Add action outlines
- [X] Update Sprites
- [X] Update portraits
- [X] Implement animations
- [X] Add shader effects for boosted and shielded characters
- [ ] Create test battle for balancing
	- [ ] Create sparring scene
- [ ] Create bard unit
- [ ] Create tank unit
- [X] Create minion unit
- [ ] Add damage, heal, block, and boost text particles

# BUGS:
- [ ] CPU boost action targets allies who have no actions left. They should only pick a target from the remaining characters with actions to take. 
