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
### Version Control: **Git + GitHub**
### Assets
- **Characters:** Existing Chibiki Royale sprites
- **Cards:** Simple rectangular frames with icons/text
- **UI:** Minimalist, clean
- **Fonts:** Free Google Fonts

## 🤝 CREDITS

**Developer:** vethre  
**Engine:** Godot 4.x  
**Characters:** Chibiki Royale universe  
**Inspired by:** Slay the Spire, Balatro, Monster Train

---

## 📬 CONTACT

- GitHub: [vethre](https://github.com/vethre)
- Telegram: [vethre](t.me/witvtr)

---
