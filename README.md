# 🕹️ VIBES: The Pixel Haptics Lab

> **A tactile audio-haptic synthesis sandbox and physics testing playground built with Flutter.**  
> Blending 16-bit Minecraft-inspired retro-pixel aesthetics with butter-smooth 120Hz iOS spring physics, real-time waveform visualizers, and hardware-coupled PCM synthesis.

---

## ⚡ Architecture & Feature Overview

### 1. 🔬 Waveform & Haptic Generator
- **Frequency Control:** Dynamic sweep from **1 Hz to 1000 Hz**, featuring an automatic **Linear Resonant Actuator (LRA) Sweet-Spot Detector** at 150 Hz – 250 Hz (natural mechanical resonance of smartphone haptic motors).
- **Amplitude / Intensity:** Continuous precision scaling from **0% to 100%**.
- **Supported Waveforms:**
  - `Sine`: Smooth harmonic vibration, minimal mechanical distortion.
  - `Square`: Odd-harmonic rich; sharp, industrial buzz.
  - `Triangle`: Linear kinetic slope with clear directional change.
  - `Sawtooth`: Directional jerk ($\frac{da}{dt}$) profile for tactile ramping.
  - `Pulse Train`: Discrete mechanical micro-ticks and Geiger clicks.
- **Timing Engine:** Configurable burst durations (50 ms – 2000 ms), duty cycle pulse-width modulation (5% – 95%), and seamless loop mode.

### 2. 🎵 Coupled Audio-Haptic Engine
- **In-Memory 16-Bit PCM Synthesis:** Generates instantaneous RIFF/WAV audio buffers synthesized on-the-fly to couple acoustic frequency with motor displacement.
- **Dual Independent Sinks:** Toggle the physical haptic actuator and the audio tone generator independently or in synchronized lockstep.
- **Envelope Shaping:** 15ms attack and 25ms decay smoothing applied to synthesized waveforms to prevent audible speaker clipping or pops.

### 3. 📊 Physics Telemetry & Data Exporter
- **Live CRT Pixel Oscilloscope:** Real-time animated canvas oscillogram displaying phosphor trace glow, grid reticles, period $\tau = \frac{1}{f}$, and estimated motor G-force.
- **Data Export Formats:**
  - **JSON Profile:** Complete waveform metadata, time-domain intensity array, and event history.
  - **CSV Matrix:** Tabular dataset ready for MATLAB, Python NumPy, or spreadsheet import.
- **Native OS Share Sheet:** One-tap export to Slack, Email, Google Drive, or local storage.

### 4. 💎 The Preset Vault ("Play Store Vibes")
- Curated presets:
  - 🌋 **Seismic Shock:** 45 Hz tectonic rumble.
  - 🫀 **Heartbeat Echo:** 85 Hz cardiac diastolic thud.
  - 🟥 **Redstone Clock:** 160 Hz square mechanical repeater.
  - 🐱 **Sub-bass Purr:** 180 Hz resonant purr at peak LRA coupling.
  - ☢️ **Cosmic Geiger:** 340 Hz high-frequency ionizing radiation burst.
  - ⌨️ **Cherry MX Click:** 220 Hz tactile switch click.
- Built-in Custom Preset Creator with emoji avatars, user ratings, and instant transfer to the Synthesis Lab.

---

## 🎨 UI/UX Design System Tokens

| Token | Hex Value | Role |
| :--- | :--- | :--- |
| **Deep Void** | `#121216` | Root background & CRT frame |
| **Obsidian Slate** | `#1E1F29` | Container surface & cards |
| **Surface Border** | `#2E3040` | 2px chunky pixel border |
| **Emerald XP** | `#55FF55` | Primary action & active oscilloscope beam |
| **Diamond Cyan** | `#00E5FF` | Frequency stats, labels & secondary action |
| **Redstone** | `#FF3B30` | Halt, danger & destructive triggers |
| **Gold Nugget** | `#FFD700` | Hardware resonance sweet-spot indicator |
| **Pixel White** | `#F4F4F4` | Primary high-contrast numeric readouts |
| **Muted Stone** | `#8E8E93` | Telemetry units and inactive states |

---

## 📁 Repository Directory Structure

```
vibes_app/
├── .github/
│   └── workflows/
│       └── build_and_release.yml     # Automated CI/CD (Test, Build, Sign, Release)
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml  # VIBRATE permission & hardware flags
│   │   └── build.gradle             # Target SDK 34, Keystore signing
│   ├── build.gradle
│   └── settings.gradle
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── presets.dart         # Curated vault profiles
│   │   └── theme/
│   │       ├── pixel_borders.dart   # Stepped pixel border decorations
│   │       └── vibes_theme.dart     # Retro typography & palette
│   ├── models/
│   │   ├── preset_item.dart         # Vault preset model
│   │   └── waveform_config.dart     # Physics parameters & sampling functions
│   ├── providers/
│   │   └── haptic_lab_provider.dart # Centralized state management
│   ├── services/
│   │   ├── audio_synth_service.dart # Real-time 16-bit PCM WAV audio synthesizer
│   │   ├── haptics_service.dart     # Platform haptic & amplitude engine
│   │   └── telemetry_service.dart   # JSON/CSV exporter & metrics logger
│   ├── views/
│   │   ├── lab_screen.dart          # Primary synthesis sandbox
│   │   ├── vault_screen.dart        # Community & preset explorer
│   │   ├── telemetry_screen.dart    # Physics metrics & telemetry exporter
│   │   └── settings_screen.dart     # Actuator diagnostics & calibration
│   ├── widgets/
│   │   ├── pixel_badge.dart         # Retro status tags
│   │   ├── pixel_bottom_nav.dart    # 4-tab retro navigation
│   │   ├── pixel_button.dart        # 3D depressed kinetic tactile button
│   │   ├── pixel_card.dart          # Beveled pixel container
│   │   ├── pixel_oscilloscope.dart  # Real-time animated CRT visualizer
│   │   ├── pixel_slider.dart        # Stepped slider with micro-haptic ticks
│   │   └── pixel_switch.dart        # Minecraft lever-style toggle switch
│   └── main.dart                    # Application entry point & theme setup
├── test/
│   └── waveform_test.dart           # Math, physics & serialization unit tests
├── analysis_options.yaml            # Zero-error linting configuration
└── pubspec.yaml                     # Dependencies & asset declarations
```

---

## 🚀 Automated GitHub Actions CI/CD Setup

The workflow at `.github/workflows/build_and_release.yml` automatically triggers on Git tags (`v*`) or manual triggers (`workflow_dispatch`).

### What It Does:
1. Sets up **Java 17** and **Flutter Stable (3.19.6)** with dependency caching.
2. Executes `flutter analyze` and unit physics test suites (`flutter test`).
3. Signs Android artifacts (supports production keystore secret or automated fallback self-signing).
4. Compiles:
   - `vibes-universal-release.apk`
   - `vibes-arm64-v8a-release.apk`
   - `vibes-armeabi-v7a-release.apk`
   - `vibes-x86_64-release.apk`
   - `vibes-release.aab` (Google Play Bundle)
5. Generates **cryptographic SHA-256 checksums** (`checksums.txt`).
6. Creates a **GitHub Release** and attaches all assets automatically.

### Configuring Production Keystore (Optional)
To sign with your Google Play release keystore, add these GitHub Repository Secrets:
- `KEYSTORE_BASE64`: Base64 encoded `.jks` file (`base64 -w 0 upload-keystore.jks`)
- `KEYSTORE_PASSWORD`: Keystore store password
- `KEY_ALIAS`: Key alias
- `KEY_PASSWORD`: Key private password
*(If omitted, CI will automatically generate a self-signed release key so builds never fail).*

---

## 🧪 Local Development & Execution

```bash
# 1. Clone repository
git clone https://github.com/your-username/vibes.git
cd vibes

# 2. Install dependencies
flutter pub get

# 3. Run physics tests
flutter test

# 4. Launch on Android device / iOS simulator
flutter run
```
