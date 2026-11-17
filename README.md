# ⚡ PulseFit — Clean Architecture Fitness Tracker App

A modern, offline-first personal fitness tracking application built with **Flutter 3** following **Clean Architecture (MVVM)** principles. Track daily activities, steps, calories burned, active duration, and log workouts manually with visual weekly charts and statistics.

---

## 🏃 Key Features

- 📊 **Dynamic Daily Dashboard**:
  - Live progress indicators for **Steps** (goal: 10,000), **Calories Burned** (goal: 650 kcal), and **Active Minutes** (goal: 45 min).
  - Quick step logger (`+500`, `+1,000`, `+2,500` steps) for immediate updates on the go.
- 📈 **Weekly Activity Bar Chart**:
  - Visual Monday–Sunday graph tracking active workout duration with responsive scaling and highlighting today's progress.
- 📝 **Manual Workout Logging (Modal Sheet)**:
  - Supports multiple exercise categories: **Running 🏃**, **Cycling 🚴**, **Gym / Strength 🏋️**, **Swimming 🏊**, **Walking 🚶**, **Yoga 🧘**, and **HIIT ⚡**.
  - Smart automatic calorie estimation based on duration and sport intensity, with full manual override.
  - Optional distance tracking (km) and notes/descriptions.
- 📜 **Full Activity History & Search**:
  - Real-time search filter by sport or description.
  - Aggregated career stats banner (Total Workouts, Total Calories Burned, Total Minutes Active).
  - Safe record deletion with confirmation dialogs.
- 💾 **Local Offline Persistence**:
  - Persists all workout logs and steps locally across sessions using `shared_preferences`.
- 🎨 **Modern High-Contrast Fitness UI**:
  - Emerald Green (`#10B981`) and Electric Cyan (`#06B6D4`) with Calorie Orange accents, fully supporting dark and light themes.

---

## 🏛️ Clean Architecture (MVVM) Overview

```text
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart               # Service Locator DI Container
│   ├── errors/
│   │   └── failures.dart                      # Core Failures & Exceptions
│   └── theme/
│       └── app_theme.dart                     # Modern dark & light fitness themes
│
├── domain/                                    # Enterprise & Business Rules (Pure Dart)
│   ├── entities/
│   │   └── activity_entity.dart               # Workout activity entity
│   ├── repositories/
│   │   └── fitness_repository.dart            # Repository contract
│   └── usecases/                              # Single-responsibility interactors
│       ├── get_activities_usecase.dart        # Retrieve logged activities
│       ├── log_activity_usecase.dart          # Save new workout
│       ├── delete_activity_usecase.dart       # Delete workout by ID
│       ├── get_daily_steps_usecase.dart       # Retrieve daily steps
│       └── update_daily_steps_usecase.dart    # Update daily steps count
│
├── data/                                      # Data Access Layer
│   ├── datasources/
│   │   └── fitness_local_data_source.dart     # SharedPreferences local storage & seed data
│   ├── models/
│   │   └── activity_model.dart                # JSON serializable model extending Entity
│   └── repositories/
│       └── fitness_repository_impl.dart       # Repository implementation
│
├── presentation/                              # UI Layer (MVVM)
│   ├── view_models/
│   │   └── fitness_view_model.dart            # Reactive ChangeNotifier ViewModel
│   ├── views/
│   │   ├── dashboard_view.dart                # Summary dashboard with metrics & weekly chart
│   │   └── activity_history_view.dart         # Full activity history with search & statistics
│   └── widgets/
│       ├── metric_card_widget.dart            # Steps, Calories, Active minutes cards
│       ├── weekly_chart_widget.dart           # Visual Monday-Sunday bar chart
│       ├── log_activity_dialog.dart           # Interactive bottom sheet to log workouts
│       └── activity_list_item_widget.dart     # Individual activity card with icons & delete
│
└── main.dart                                  # Application entrypoint with async DI bootstrapping
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.47.x or later)
- Dart SDK (3.13.x or later)

### Installation & Run

```bash
cd e:\rout\fitness_tracker_app
flutter pub get
flutter run
```

### Running Tests & Static Analysis

```bash
# Run unit & widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 📄 License
Open-source under the MIT License.
