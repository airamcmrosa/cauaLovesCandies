docs/architecture/architecture.md [generated with file_gen tool]

Here is the refined, production-grade technical architecture document (`architecture.md`) written in English, fully incorporating the **Pseudo-3D / 2.5D perspective conveyor belt illusion**, zero-backend requirements, and lifecycle coordination.

```markdown
---
title: System Architecture Specification
project: Cauã Loves Candies - Birthday Game Edition
version: 1.1.0-mvp
createdAt: 2026/10/29
domain_scope:
  input: "Frictionless Web Mobile via QR Code (Safari iOS / Chrome Android)"
  output: "Flutter Web (CanvasKit/Skwasm fallback) + Flame Engine 2D/2.5D"
  core_pattern: "Pseudo-3D Perspective Projection / Zero-Backend Client-Side / State-Driven Game Loop"
reference: "/docs/product/product-vision.md"
---

# Technical Architecture: Cauã Loves Candies

> **Scope Note:** This architecture document sets the technical foundation, rendering pipeline, component hierarchy, and perspective projection mathematics for the 100% client-side web deployment. Detailed functional user stories live in `/docs/product/stories/` and are loaded JIT.

---

## 1. 🏗️ High-Level Architectural Principles

- **Zero-Backend Footprint ($0.00 Opex):** Completely client-side static bundle hosted on GitHub Pages or Vercel Free Tier. No database, server, or cloud function dependencies.
- **Sub-3s Web Mobile SLA:** Total payload size kept strictly under 3.5 MB uncompressed. Aggressive asset compression using `.webp` for textures and compressed `.mp3`/`.ogg` for audio.
- **Pseudo-3D Perspective (2.5D Illusion):** Instead of an expensive, battery-draining WebGL 3D engine, the game uses mathematical perspective projection rendered directly on the 2D Flame canvas at constant 60 FPS.
- **Single-Threaded Main Loop Coordinator:** The Main Game Loop acts as the single source of truth for all game events, collision evaluations, and score calculations.

---

## 2. 📐 Perspective Projection & Conveyor Belt Mechanics (Pseudo-3D)

### Visual Illusion Geometry

The conveyor belt is mapped as an inverted trapezoid extending from the user's viewport bottom (near-plane) inward to a vanishing point on the horizon line (far-plane) where Cauã's head sits:

```text
       ====================== [ SKY / CELEBRATION ] ======================
                                 (0, yHorizon)
                                [ CAUÃ HEAD ]   <-- Far plane (Mouth target, scale: 0.25)
                                    \   /
                                     \ /
                                   /  o  \       <-- z = 0.75 (scale: 0.44, high depth)
                                  /       \
                                 /    o    \     <-- z = 0.40 (scale: 0.70, mid-track)
                                /           \
                               /      O      \   <-- z = 0.00 (scale: 1.00, user touch origin)
     ======================= [ CONVEYOR INTAKE ] =======================
                               (xCenter, yBottom)

```

### Projection Mathematics

Each item on the conveyor belt tracks a normalized depth coordinate $z \in [0.0, 1.0]$:

* $z = 0.0$: Spawn point at the bottom screen edge (closest to the user).
* $z = 1.0$: Arrival point at Cauã's mouth on the horizon line.

Given depth progress $z(t)$, world positions and screen scales are derived dynamically on every frame update:

$$\text{scale}(z) = \text{scale}_{\text{bottom}} + (\text{scale}_{\text{horizon}} - \text{scale}_{\text{bottom}}) \cdot z$$

$$y(z) = y_{\text{bottom}} + (y_{\text{horizon}} - y_{\text{bottom}}) \cdot z$$

$$x(z) = x_{\text{spawn}} + (x_{\text{mouth}} - x_{\text{spawn}}) \cdot z$$

* **Hitbox & Decision Boundary:** Evaluated when $z \ge 0.95$.
* If Cauã's mouth is **OPEN**: Item is ingested. Sweets give $+2$ pts; Fruits give $+1$ pt; Forbidden items trigger damage ($-1$ HP) and play a screen shake effect.
* If Cauã's mouth is **CLOSED**: Item strikes closed teeth, deflects laterally, and despawns without penalizing the player.



---

## 3. 🧩 Flame Component Hierarchy

```text
CauaCandiesGame (FlameGame with TapCallbacks)
├── CameraComponent & World
│   ├── ConveyorBeltComponent (Trapezoidal visual lane with scrolling stripes)
│   ├── CauaPlayerComponent (Positioned at Horizon line; toggles MouthOpen / MouthClosed sprites)
│   ├── ItemSpawnerComponent (Emits FoodItemComponent instances with progressive frequencies)
│   │   └── FoodItemComponent (Updates internal z-depth, scale, and computed canvas coordinates)
│   └── ParticleCelebrationComponent (Confetti bursts triggered on victory/phase transitions)
└── Managers (Plain Dart Domain Controllers)
    ├── GameManager (Tracks active Level [1..3], current Score, HP [max: 3], GameState)
    └── AudioManager (Pre-cached SFX pools and looping BGM using flame_audio)

```

---

## 4. 🔄 State Management & Progressive Phase Progression

```text
   ┌─────────────────────────────────────────────────────────┐
   │                  ONBOARDING / TITLE SCREEN              │
   │  • Displays "Cauã Loves Candies" logo                    │
   │  • Audio unlock prompt (Web Audio policy compliance)    │
   │  • Hands-on Visual Finger Tap Overlay (US06)           │
   └────────────────────────────┬────────────────────────────┘
                                │ Tap to Start
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │                         PHASE 1                         │
   │  • Speed: 1.2x (Base +20%)                            │
   │  • Target: 10 Points                                    │
   │  • Item Composition: 70% Sweets, 20% Fruit, 10% Hazard  │
   └────────────────────────────┬────────────────────────────┘
                                │ Score >= 10
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │                         PHASE 2                         │
   │  • Speed: 1.44x (Medium scroll)                         │
   │  • Target: 20 Points                                    │
   │  • Item Composition: 50% Sweets, 30% Fruit, 20% Hazard  │
   └────────────────────────────┬────────────────────────────┘
                                │ Score >= 20
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │                         PHASE 3                         │
   │  • Speed: 1.728x (Fast celebration rush)                 │
   │  • Target: 30 Points                                    │
   │  • Item Composition: High volume of bonus items         │
   └────────────────────────────┬────────────────────────────┘
                                │ Victory Reached
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │                CONFETTI VICTORY OVERLAY                 │
   │  • Particle confetti explosion                          │
   │  • "Happy 6th Birthday, Cauã!" banner                   │
   │  • Instant Play Again action (Zero-latency loop reset)  │
   └─────────────────────────────────────────────────────────┘

```

---

## 5. ⚡ Web Mobile Performance & Audio Constraints

1. **Web Audio Unlock:** Mobile browsers (Safari/Chrome) block autoplaying audio. The initial start screen requires an explicit user tap to release the `AudioContext` before BGM loops start.
2. **Fixed Virtual Resolution:** Renders inside a responsive logical viewport (e.g., standard aspect ratio $9:16$ / $720 \times 1280$) letterboxed inside the mobile browser window to prevent canvas distortion across irregular phone screen aspect ratios.
3. **Garbage Collection (GC) Optimization:** Food items arriving past $z > 1.0$ or deflected are recycled or removed cleanly via `removeFromParent()` to keep frame rates locked at 60 FPS without GC frame drops.

---

## 6. 🚀 CI/CD & Static Delivery Pipeline

* **Repository Hosting:** GitHub repository with an automated GitHub Actions runner (`.github/workflows/deploy.yml`).
* **Compilation Command:**
```bash
flutter build web --release --web-renderer canvaskit --base-href "/cauaLovesCandies/"

```


* **Deployment Destination:** Published automatically to GitHub Pages (`gh-pages` branch) or Vercel static output on every commit pushed to `main`.

