# 🏰 Sir Bounce-a-Lot: The Great Bouncy Castle Rescue

A physics-based platformer built in the **Godot Engine (Godot 4.x)** inspired by the charm, visual reactiveness, and tactile squishy physics of **Snipperclips**!

Play as **Sir Bounce-a-Lot**, a noble, squishy prince on a daring quest to rescue **Princess Aurelia**, who has been trapped at the pinnacle of the Grand Inflatable Castle by **Ignis the Inflatable Dragon**!

---

## 🎮 How to Play

### Option 1: In Godot Engine 4
1. Open **Godot Engine 4** (4.2, 4.3, or newer).
2. Click **Import** and select the folder `c:\Users\munke\Downloads\Sir Bounce a Lot\project.godot`.
3. Press **F5** (or the **Play** button in the top right) to launch!

### Option 2: Instant Play in Your Browser
- Simply double-click [`index.html`](file:///c:/Users/munke/Downloads/Sir Bounce a Lot/index.html) in any modern browser (Chrome, Edge, Firefox) to play immediately with full 60fps physics, Web Audio synthesizer effects, and all 4 levels!

---

## 🕹️ Controls

| Action | Keyboard Controls | Gamepad | Description |
| :--- | :--- | :--- | :--- |
| **Move** | `A` / `D` or `←` / `→` | Left Stick / D-Pad | Smooth horizontal movement with bouncy inertia |
| **Jump** | `Space` / `W` / `↑` | Button A / Cross | Snappy jump with springy squash & stretch |
| **Squash & Charge** | Hold `S` or `↓` on ground | Hold Down / Button B | Squash flat like a compressed spring, then release to launch into a colossal **Super-Bounce**! |
| **Ground Pound** | Press `S` or `↓` in mid-air | Press Down / Button B | Slam down with comical anvil force; triggers shockwaves, launches seesaws, and pops dragon bubbles! |
| **Perfect Bounce** | Press `Jump` right as you hit a trampoline | Button A on impact | Timed rhythmic bounce that awards rainbow star particles and 1.5x launch height! |
| **Reset Level** | `R` | Select / Back | Quickly reset the current stage |

---

## 🌟 Cool Physics Mechanics & Features

### 1. Snipperclips-Style Visuals & Expressive Reactivity
- **Expressive Googly Eyes**: Eyes smoothly track the player's movement direction, widen with panic when falling from heights, squint with concentration during super-bounce charging, and turn into happy smiles `(^o^)` when soaring high.
- **Dynamic Soft-Body Spring Physics**: Natural harmonic squash-and-stretch oscillation (`F = -k*x - c*v`) on jump takeoff, landing impacts, and wall bumps.
- **Inflatable Vinyl Aesthetic**: Bright pastel color palette, rounded shapes, stitched seam dots, and glossy cushion highlights.

### 2. Kinetic Contraptions & Checkpoints
- **Inflatable Checkpoint Banners**: Sleeping lavender pennants that spring awake into royal turquoise and gold with a cheerful face `(^o^)` and starburst sparkles upon contact. Sets your respawn point so falling off or taking damage won't send you back to the start of the level!
- **Responsive Inflatable Trampolines**: Spring coils visibly compress under player weight and bounce back elastically.
- **Pinball Bumpers**: Radial rebound kickback pads that flash neon, play sweet chimes, and blast the prince in the direction of contact.
- **Physics Seesaw Catapults**: Ground-pounding one end of a teeter-totter launches objects or the player on the opposite pad high up to distant castle spires!
- **Air Updraft Blowers**: Floating wind vents that gently carry the prince and bouncy beach balls up vertical corridors.
- **Bouncy Beach Balls**: RigidBody2D physics objects that can be rolled, pushed, and catapulted onto switches.
- **Swinging Pendulums**: Inflatable spiky hazard balls swinging on elastic tethers.

---

## 🐉 The Boss: Ignis the Inflatable Dragon

The final encounter in **Level 4** tests all of your bouncy physics skills:
- **Phase 1**: Ignis hovers across the arena, spitting bouncing fireball bubbles. Time your trampoline leaps to Ground-Pound into his glowing bouncy belly!
- **Phase 2 (HP ≤ 3)**: Ignis stomps down to the floor, sending shockwaves through the inflatable ground. Use the central seesaw catapult to launch yourself over him and strike from above!
- **Phase 3 (Enraged Mode)**: Ignis turns fiery crimson, swooping rapidly across the arena with bullet-speed bouncing fireballs.
- **Defeat Animation**: Landing the final blow pops his inflatable armor, deflating Ignis like an untied balloon with comical spinning squeaks, safely unlocking Princess Aurelia's bubble cage!

---

## 📁 Project Structure

```
Sir Bounce a Lot/
├── project.godot                     # Godot 4 project definition (gl_compatibility, inputs, autoloads)
├── icon.svg                          # Snipperclips-styled vector icon
├── index.html                        # Standalone instant browser-playable version
├── scenes/
│   ├── characters/
│   │   ├── prince.tscn               # Prince CharacterBody2D rig with squash/stretch & particles
│   │   ├── princess.tscn             # Princess Aurelia with bubble cage & cheering animations
│   │   └── dragon_boss.tscn          # Ignis Dragon multi-phase boss scene
│   ├── levels/
│   │   ├── level_1.tscn              # "The Inflatable Courtyard"
│   │   ├── level_2.tscn              # "The Bouncing Chambers & Seesaws"
│   │   ├── level_3.tscn              # "The Royal Cloud Spire"
│   │   └── level_4_boss.tscn         # "Boss Arena: Ignis the Bouncy Dragon"
│   ├── objects/
│   │   ├── checkpoint.tscn           # Inflatable respawn banner with spring animation
│   │   ├── bouncy_platform.tscn      # Inflatable vinyl platform with stitched seams
│   │   ├── trampoline.tscn           # Dynamic spring pad
│   │   ├── pinball_bumper.tscn       # Radial impulse pinball bumper
│   │   ├── seesaw.tscn               # Physics catapult teeter-totter
│   │   ├── air_blower.tscn           # Updraft wind vent
│   │   ├── bouncy_ball.tscn          # Physics beach ball
│   │   ├── collectible_ring.tscn     # Golden ring with sparkle particles
│   │   ├── goal_gate.tscn            # Inflatable gateway with victory ribbon & confetti
│   │   ├── pendulum.tscn             # Swinging spiky ball obstacle
│   │   └── fire_bubble.tscn          # Dragon's bouncy fireball projectile
│   └── ui/
│       ├── hud.tscn                  # Heart life icons, ring counter, boss HP bar
│       ├── main_menu.tscn            # Animated title screen with level picker
│       └── victory_screen.tscn       # Celebratory rescue screen with victory dance
└── scripts/
    ├── autoload/
    │   ├── game_manager.gd           # Scoring, lives, transitions, and camera shakes
    │   └── sound_manager.gd          # Procedural 16-bit audio synthesizer (zero external dependencies)
    ├── characters/
    │   ├── prince.gd & visual.gd     # Prince mechanics & Snipperclips procedural drawing
    │   ├── princess.gd               # Princess bubble cage & animations
    │   └── dragon_boss.gd & visual.gd# Multi-phase AI & animated wings
    └── objects/                      # Component scripts for all contraptions & hazards
```

---

## 🎵 100% Procedural Audio & Graphics
- **Zero Missing Assets**: All audio is synthesized algorithmically via custom 16-bit PCM waveform generators (boings, springs, dings, squeaks, roars, and cheerful melodic background music).
- **Crisp Vector Graphics**: Characters and props use procedural CanvasItem vector drawing, meaning razor-sharp visuals at any screen resolution or zoom scale!
