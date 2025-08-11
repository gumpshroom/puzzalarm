**Project Context**
This is an iOS and WatchOS alarm clock app written in Swift that makes users solve puzzles in order to turn off or snooze the alarm. On WatchOS, it should also use biometric data to determine if a user has fallen asleep after waking up to an alarm and set it off again.

**Design Details**
The design of the app should be minimalistic, sleek, modern, and true to Apple's design principles; modeled after the stock iOS/WatchOS Alarm feature. Animations and graphics for puzzles/games should be responsive and interesting, using only vector graphics. Graphic design for games should be vector-based only and minimalist but with small tasteful details. Puzzles and games should have intuitive and simple controls, relying less on the the touchscreen when it is possible to use a more physical form of input. Haptics should be thorough and immersive when appropriate but not intrusive.

**Feature Details**
- multiple alarms
- alarm sound choice
- vibration pattern choice
- alarm silent mode (vibrate only)
- gradual and smooth wake up (slowly increasing sound volume/vibration intensity)
- weekly alarm schedule (repeat on certain days)
- detect if user has fallen back asleep (WatchOS)
- puzzle/game to confirm wake up
- in-depth stat tracking, including # of snoozes, puzzle/game completion time, and time/frequency of falling back asleep
- robust and comprehensive customization system for all features

**Puzzle and Game Details**
When the puzzle/game option is enabled for an alarm, users will be prevented from turning off or snoozing their alarm until they pass their chosen puzzle or game's objective.
- Math Puzzle: complete a certain number of math problems of customizable difficulty within a chosen time limit to pass
- Marble Maze: tilt the device to guide a ball through a maze of customizable difficulty a chosen amount of times to pass
- Water: pour water from one virtual cup into another by tilting the phone vertically on iOS and using the crown on Watch until it reaches a random specified level a chosen amount of times to pass
