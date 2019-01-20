# implementation of a cellular automaton i found

## keyboard things:

| key  | action |
| ------------- | ------------- |
| space | start/pause simulation |
| s | single step |
| e | clear map |
| p | enable/disable peeking (highlighting things that would change in the next frame) |
| u | undo (save loading, board clearing, single-step, play starting) |
| r | randomize the board |
| h | highlight the cell whose value would be picked up in the next frame |
| v | enable/disable vector field, which shows all transformations (grayed out arrows are those whose values don't change) |

`0-9` to load save, "o" + `[0-9]` to save