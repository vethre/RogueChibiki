# 🎮 ROGUE CHIBIKI

**A deckbuilding roguelite mobile game featuring characters from Chibiki Royale**

---

## 📋 PROJECT OVERVIEW

**Genre:** Roguelike Deckbuilder (Slay the Spire / Balatro inspired)  
**Platform:** Android (mobile-first)  
**Engine:** Godot 4.x  
**Language:** GDScript  
**Art Style:** Chibiki Royale character sprites + minimalist UI  
**Target:** Solo developer, manageable scope, actually finishable

---

## 🎯 CORE CONCEPT

A turn-based card battler where you pick a Chibiki character, build a deck through strategic choices, and fight through encounters. Each run is unique. Death means progress—unlock new characters and cards to try new strategies.

**Key Hook:** Characters from Chibiki Royale universe, but in a completely different genre. Familiar faces, fresh gameplay.

---

## 🔄 CORE GAME LOOP

```
1. Main Menu
   ↓
2. Character Select (pick your Chibiki)
   ↓
3. Start Run (10-12 encounters)
   ↓
4. Combat Encounter
   - Draw hand of cards
   - Play cards (attack/defend/special)
   - Enemy telegraphs move
   - Resolve damage/effects
   - Repeat until win/loss
   ↓
5. Reward Screen (pick 1 of 3 options)
   - New card
   - Upgrade existing card
   - Relic/power
   ↓
6. Next Encounter (combat, shop, event, or boss)
   ↓
7. Run Ends (win final boss OR die)
   ↓
8. Earn XP based on performance
   ↓
9. Unlock new Chibiki or cards
   ↓
10. Back to Main Menu (try again with new tools)
```

---

## 🎴 COMBAT SYSTEM

### Turn Structure
1. **Player Turn**
   - Start with Energy (default: 3)
   - Draw 5 cards from deck
   - Play cards (costs Energy)
   - End turn when out of Energy or manually pass
   
2. **Enemy Turn**
   - Enemy telegraphs their action (shown above enemy sprite)
   - Execute action (attack, defend, apply debuff, etc.)
   - Player takes damage/effects

3. **Repeat** until player HP = 0 OR enemy HP = 0

### Card Types
- **Attack** – Deal damage to enemy
- **Defend** – Gain block (temporary shield)
- **Skill** – Special effects (draw cards, gain energy, debuffs, etc.)
- **Power** – Persistent buffs/debuffs for the rest of combat

### Resources
- **HP (Health Points)** – You die at 0 HP
- **Energy** – Refreshes each turn, used to play cards
- **Block** – Temporary shield, resets to 0 each turn
- **Deck** – Your cards shuffle when exhausted

---

## 👾 CHIBIKI CHARACTERS

Each Chibiki has:
- Unique **starting deck** (10 cards)
- Unique **passive ability**
- Unique **card pool** (unlocked via character mastery)

### MVP Character Roster (4 total)

#### 1. **TANK CHIBIKI** (Unlocked by default)
- **Passive:** Start each combat with +5 Block
- **Playstyle:** High HP, defensive cards, counter-attacks
- **Starting Deck:** 5x Strike, 3x Defend, 2x Iron Wall

#### 2. **AGGRO CHIBIKI** (Unlocked by default)
- **Passive:** Deal +1 damage with all Attack cards
- **Playstyle:** Fast damage, low defense, risk/reward
- **Starting Deck:** 7x Strike, 2x Defend, 1x Rage

#### 3. **CONTROL CHIBIKI** (Locked – requires 500 XP)
- **Passive:** Enemies start combat with -1 Strength
- **Playstyle:** Debuffs, status effects, long battles
- **Starting Deck:** 4x Strike, 4x Defend, 2x Weaken

#### 4. **COMBO CHIBIKI** (Locked – requires 1000 XP)
- **Passive:** Every 3rd card played each turn costs 0 Energy
- **Playstyle:** Card cycling, big turns, synergy-focused
- **Starting Deck:** 5x Strike, 3x Defend, 2x Quick Draw

---

## 🃏 CARD EXAMPLES

### Basic Cards (all characters start with these)
- **Strike** (1 Energy) – Deal 6 damage
- **Defend** (1 Energy) – Gain 5 Block

### Tank Chibiki Cards
- **Iron Wall** (1 Energy) – Gain 8 Block
- **Counter** (2 Energy) – Gain 6 Block. Next time you take damage this turn, deal that damage back.
- **Fortify** (2 Energy, Power) – Gain +2 Block at the start of each turn.

### Aggro Chibiki Cards
- **Rage** (0 Energy) – Deal 3 damage. Draw 1 card.
- **Heavy Strike** (2 Energy) – Deal 12 damage.
- **Berserk** (1 Energy, Power) – Deal +2 damage with all Attack cards. Take 1 damage at end of turn.

### Control Chibiki Cards
- **Weaken** (1 Energy) – Enemy deals -2 damage for 2 turns.
- **Poison** (1 Energy) – Apply 3 Poison to enemy (takes damage at end of turn).
- **Neutralize** (0 Energy) – Deal 3 damage. Apply 1 Weak.

### Combo Chibiki Cards
- **Quick Draw** (1 Energy) – Draw 2 cards.
- **Shiv** (0 Energy) – Deal 4 damage. Exhaust.
- **Blade Dance** (1 Energy) – Add 2 Shivs to hand.

---

## 🏆 PROGRESSION SYSTEMS

### 1. Account XP (Meta Progression)
- Earn XP at end of each run based on:
  - Floors cleared
  - Enemies defeated
  - Boss kills
- XP unlocks:
  - New Chibiki characters
  - Permanent upgrades (optional: +5 starting HP, +1 starting relic slot, etc.)

### 2. Character Mastery
- Each Chibiki levels up independently
- Unlocks more cards for that character's pool
- **Mastery Levels:**
  - Level 1 (default): 15 cards available
  - Level 2 (100 XP): +5 new cards
  - Level 3 (250 XP): +5 new cards
  - Level 4 (500 XP): +5 new cards (full pool unlocked)

### 3. Run-Specific Progression (resets each run)
- Gain cards after combat
- Upgrade cards (e.g., Strike → Strike+ deals 9 damage instead of 6)
- Collect relics (passive buffs for the run)

---

## 🎁 RELICS (PASSIVE ITEMS)

Relics provide permanent buffs for the duration of a run.

### MVP Relics (10 total)

1. **Red Mask** – Start each combat with +1 Energy.
2. **Vampire Fang** – Heal 1 HP whenever you deal damage.
3. **Rusty Coin** – Gain 50 extra gold.
4. **Thorns** – Whenever you gain Block, deal 1 damage to enemy.
5. **Lucky Dice** – 10% chance to draw an extra card each turn.
6. **Burning Blood** – Heal 3 HP after each combat.
7. **Cracked Hourglass** – Start combat with 1 extra card in hand.
8. **Shielding Amulet** – Gain 3 Block at the start of each turn.
9. **Glass Cannon** – Deal +3 damage with all attacks. Max HP -10.
10. **Mystic Prism** – Whenever you play 5 cards in a turn, draw 1 card.

---

## 🗺️ RUN STRUCTURE

### Encounter Types (10-12 total per run)

1. **Combat** (70% of encounters)
   - Fight 1 enemy
   - Earn card reward after

2. **Elite Combat** (10% of encounters)
   - Fight stronger enemy
   - Better rewards (rare card or relic)

3. **Shop** (10% of encounters)
   - Spend gold to:
     - Buy cards
     - Remove cards from deck
     - Buy relics
     - Heal HP

4. **Event** (10% of encounters)
   - Random event with choices
   - Examples:
     - "Mysterious Shrine: Sacrifice 10 HP to gain a relic"
     - "Traveling Merchant: Pay 50 gold for a rare card"
     - "Rest Site: Heal 20 HP OR upgrade 1 card"

5. **Boss** (Final encounter)
   - Tough enemy with unique mechanics
   - Beating boss = run victory

---

## 🎨 UI/UX DESIGN

### Screens

1. **Main Menu**
   - Play
   - Collection (view all cards/relics)
   - Settings
   - Exit

2. **Character Select**
   - Grid of Chibiki portraits
   - Show: Name, Passive, Mastery Level, Lock Status
   - Click to select → Start Run

3. **Map Screen** (optional for MVP, can just be linear for now)
   - Show upcoming encounters
   - Path choices (if branching)

4. **Combat Screen**
   - Top: Enemy sprite + HP bar + intent icon
   - Middle: Your HP, Energy, Block
   - Bottom: Hand of cards (draggable)
   - Side: Deck count, discard pile, draw pile

5. **Reward Screen**
   - "Pick 1 of 3" card choices
   - OR "Skip" to not take a card

6. **Victory/Defeat Screen**
   - Stats: Floors cleared, damage dealt, cards played
   - XP earned
   - "Try Again" button

---

## 🛠️ TECH STACK

### Engine: **Godot 4.x**
- Free, open-source, lightweight
- GDScript (Python-like, easy to learn)
- Great 2D support
- One-click Android export

### Version Control: **Git + GitHub**
- Keep commits small and frequent
- Write clear commit messages
- Create branches for major features

### Assets
- **Characters:** Existing Chibiki Royale sprites
- **Cards:** Simple rectangular frames with icons/text
- **UI:** Minimalist, clean (can use Godot's built-in themes)
- **Fonts:** Free Google Fonts (e.g., Roboto, Press Start 2P)

### Data Storage (for progression)
- Use Godot's **ConfigFile** or **JSON** to save:
  - Account XP
  - Unlocked characters
  - Character mastery levels
- Save file stored locally on Android device

---

## 🚀 DEVELOPMENT ROADMAP

### **PHASE 1: PROTOTYPE (Week 1-2)**
**Goal:** Playable combat loop

- [ ] Set up Godot project + Android export settings
- [ ] Create basic card scene (with name, cost, description)
- [ ] Implement hand of 5 cards
- [ ] Implement Energy system (3 per turn)
- [ ] Create 2 basic cards: Strike, Defend
- [ ] Create 1 basic enemy with simple AI
- [ ] Implement turn order (player → enemy → player)
- [ ] Win/Loss conditions
- [ ] Playtest 1 full combat

**Milestone:** You can fight 1 enemy with 2 cards and win/lose.

---

### **PHASE 2: CORE LOOP (Week 3-4)**
**Goal:** One full run end-to-end

- [ ] Add reward screen (pick 1 of 3 cards after combat)
- [ ] Create 10 total cards (5 Attack, 3 Defend, 2 Skill)
- [ ] Create 3 enemy types
- [ ] String together 5 encounters (4 combat + 1 boss)
- [ ] Add simple boss enemy (more HP, special attack)
- [ ] Victory screen (stats + "Try Again" button)
- [ ] Defeat screen (stats + "Try Again" button)

**Milestone:** You can play through a 5-encounter run and win/lose.

---

### **PHASE 3: CHARACTERS & PROGRESSION (Week 5-6)**
**Goal:** Multiple characters + unlocks

- [ ] Create character select screen
- [ ] Implement 2 Chibiki characters with unique starting decks
- [ ] Add character-specific cards (5 per character)
- [ ] Implement XP system (earned at end of run)
- [ ] Implement unlock system (new characters at XP thresholds)
- [ ] Save/Load system (persist XP and unlocks)

**Milestone:** You can unlock new characters and see progression across runs.

---

### **PHASE 4: RELICS & POLISH (Week 7-8)**
**Goal:** Add depth + juice

- [ ] Implement 5 basic relics
- [ ] Add relics to reward pool (rare drop after combat)
- [ ] Add card upgrade system (Strike → Strike+)
- [ ] Add shop encounter (buy cards, remove cards, heal)
- [ ] Polish UI (animations, SFX, particle effects)
- [ ] Add "Run History" screen (stats from past runs)

**Milestone:** Game feels complete and polished enough to share.

---

### **PHASE 5: CONTENT EXPANSION (Week 9+)**
**Goal:** More stuff to unlock

- [ ] Add 2 more Chibiki characters (total: 4)
- [ ] Expand each character's card pool to 20+ cards
- [ ] Add 5 more relics (total: 10)
- [ ] Add 2 more enemy types (total: 5)
- [ ] Add 2 more bosses (total: 3, randomized per run)
- [ ] Add event encounters (random choices with consequences)
- [ ] Implement character mastery levels

**Milestone:** Enough content for 10+ hours of gameplay.

---

### **PHASE 6: ANDROID RELEASE (Week 10+)**
**Goal:** Ship it

- [ ] Optimize for mobile (touch controls, performance)
- [ ] Add settings menu (sound, music, screen shake toggle)
- [ ] Add tutorial (first-time player experience)
- [ ] Test on multiple Android devices
- [ ] Export APK
- [ ] Share with friends via Telegram

**Milestone:** Game is playable on Android and you can send it to others.

---

## 📊 SCOPE CONTROL (TO ACTUALLY FINISH THIS)

### ✅ MVP Features (Must Have)
- 4 playable characters
- 15 cards per character (60 total)
- 5 enemy types + 1 boss
- 10 relics
- 10 encounters per run
- XP system + character unlocks
- Save/Load progression

### 🤔 Nice-to-Have (Post-MVP)
- Map with branching paths
- Daily challenges
- Leaderboards (longest run, highest score)
- More characters (6-8 total)
- More cards (30+ per character)
- Synergy achievements ("Win with 10+ Poison cards")

### ❌ Out of Scope (Don't Even Think About It)
- Multiplayer (not for v1.0)
- Online leaderboards (local only for now)
- Story mode / campaign
- Animated cutscenes
- Voice acting
- 3D anything

---

## 🧪 TESTING CHECKLIST

Before each phase, test:
- [ ] Combat feels responsive (no lag when playing cards)
- [ ] AI enemies behave correctly
- [ ] Progression saves/loads properly
- [ ] UI is readable on small screens
- [ ] Game doesn't crash when winning/losing
- [ ] No infinite loops or softlocks

---

## 🎯 SUCCESS CRITERIA

**You'll know this project is a success when:**
1. ✅ You finish it (unlike the previous 5 projects)
2. ✅ You can play 10+ runs without getting bored
3. ✅ Friends play it and say "one more run"
4. ✅ You feel proud showing it off

---

## 🔥 MOTIVATION HACKS

### When you feel like quitting:
1. **Timebox your work** – "I'll work for 30 minutes" is easier than "I'll finish this feature"
2. **Celebrate small wins** – Finished 1 card? Tweet about it. Got combat working? Tell a friend.
3. **Playtest constantly** – If it's fun to play, you'll want to keep building.
4. **Compare to Cave Miner** – Remember how this project fixes what made that one boring.

### When you're stuck:
1. **Ask Claude for help** – Send this README + your specific question
2. **Google "[problem] Godot GDScript"** – Godot community is helpful
3. **Simplify the problem** – Can't implement relics? Start with 1 relic that does 1 thing.
4. **Skip and come back** – Stuck on AI? Work on UI instead.

---

## 📝 NOTES FOR FUTURE YOU

- **This README is your north star.** When you're tempted to add features, check if it's in scope.
- **Shipping > Perfecting.** A finished 7/10 game beats an abandoned 10/10 idea.
- **You have 6-7 character sprites already.** You're not starting from zero.
- **You finished Cave Miner.** You can finish this too.

---

## 🤝 CREDITS

**Developer:** vethre  
**Engine:** Godot 4.x  
**Characters:** Chibiki Royale universe  
**Inspired by:** Slay the Spire, Balatro, Monster Train

---

## 📬 CONTACT

- GitHub: [vethre](https://github.com/vethre)
- Website: [five3.space](https://five3.space)

---

**Now stop reading and start building. You got this. 🚀**
