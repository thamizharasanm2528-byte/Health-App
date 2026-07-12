# Features

Each sub-directory is a self-contained **feature module** following Clean Architecture layers:

| Layer            | Contents                                                        |
|------------------|-----------------------------------------------------------------|
| `presentation/`  | Screens (pages), widgets, and Provider-based state management. |
| `domain/`        | Use-cases and repository contracts (abstract classes).         |
| `data/`          | Repository implementations, Hive data sources, and DTOs.      |

> Not every feature needs all three layers.  
> Presentation-only features (splash, onboarding, dashboard, settings) omit `data/` and `domain/`.

## Feature List

| Feature        | Description                                          |
|----------------|------------------------------------------------------|
| `splash/`      | Animated launch screen shown during app init.        |
| `onboarding/`  | First-run walkthrough explaining app features.       |
| `profile/`     | User profile creation and editing (name, age, etc.). |
| `dashboard/`   | Home screen aggregating data from all features.      |
| `water/`       | Daily water intake tracking with reminders.          |
| `steps/`       | Step count tracking via Health Connect / Apple Health.|
| `bmi/`         | BMI calculator and history.                          |
| `sleep/`       | Sleep duration tracking and insights.                |
| `healthy_food/`| Nutritious food suggestions and meal logging.        |
| `settings/`    | App preferences, theme toggle, notification config.  |
