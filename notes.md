# Features to Implement
- [X] Attack order should be determined by a ne "initiative" stat
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
	- [X] Create sparring scene
- [x] Create bard unit
- [x] Create tank unit
- [X] Create minion unit
- [ ] Add damage, heal, block, and boost text particles

# BUGS:
- [ ] CPU boost action targets allies who have no actions left. They should only pick a target from the remaining characters with actions to take. 
- [ ] Transition animation needs fixing.


# Game overview
The game is a turn based rpg-ish game with rogue-like elements, about being able to pick up the tab at the tavern.

The player starts in debt with the tavern keeper and must make up the required money to pay for all the consumed ale. More party members means better odds, but more ale consumed.

The game loop should be:
1. Start a run
2. take on a mission (from the tavern overworld scene)
3. explore a dungeon (gather loot, money and objectives)
4. possibly get new party members
5. repeat

At the end of each day, each character will consume a given amount of ale, costing a certain amount of gold. If the player does not have enough gold, then the party members will start to leave the team.
If the player has 1 or less party members the run is over.


