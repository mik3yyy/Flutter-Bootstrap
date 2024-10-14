# Flutter Project: Flutter-Bootstrap

This repository includes two Bash scripts, `init_project.sh` and `init_feature.sh`, designed to automate the initialization process for Flutter projects and features within those projects. These scripts follow clean architecture principles and help streamline the setup process, saving time and ensuring consistency across multiple projects.

## Table of Contents
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Code Snippets](#code-snippets)
- [Folder Structure](#folder-structure)
- [Contributing](#contributing)
- [License](#license)
- [Script Explanation](#script-explanation)

## Getting Started

To get started with this Flutter project, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mik3yyy/Flutter-Bootstrap.git
   cd Flutter-Bootstrap
   ```

2. **Initialize a new project**:
   ```bash
   ./init_project.sh projectName
   cd projectName
   ```

3. **Initialize a new feature**:
   ```bash
   ./init_feature.sh featureName
   ```

4. **Run the project**:
   ```bash
   flutter run
   ```

## Project Structure

The project is organized into several key components:

- `lib/`: Contains the main source code for the Flutter application.
- `application/`: Contains environment variables and assets.
- `pubspec.yaml`: The Flutter package manager configuration file.

## Architecture

This project follows a clean architecture approach, promoting separation of concerns and making the codebase easier to maintain. The core structure includes:

- **Core**: Contains essential services, utilities, and models.
- **Features**: Specific implementations of features (not shown in the current script but recommended for scalability).
- **Widgets**: Custom widgets used throughout the app.

## Code Snippets

### Main Application Entry

The main entry point of the application is located in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'application/.env');
  await di.init();
  runApp(MyApp());
}
```

### Dependency Injection Setup

In `lib/core/services/injection_container.dart`:

```dart
final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => LocalNotificationService());
  // Additional services...
}
```

## Folder Structure

Here’s a breakdown of the folder structure:

```
[project-name]/
├── application/
│   └── .env
├── lib/
│   ├── core/
│   │   ├── error/
│   │   ├── notifications/
│   │   ├── routes/
│   │   └── widgets/
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## Script Explanation

This repository includes two important Bash scripts to automate the project setup process:

### 1. `init_feature.sh`

The `init_feature.sh` script automates the creation of a new feature in a Flutter project. It generates the necessary folder structure and files for the **data**, **domain**, and **presentation** layers, and populates these files with boilerplate code. This helps solve the problem of manually creating directories and feature-specific files for each new feature, promoting a clean and scalable architecture for your project.

- Automatically creates files like data sources, repositories, models, entities, use cases, and bloc files.
- Populates these files with structured boilerplate code to minimize setup time and reduce human error.

### 2. `init_project.sh`

The `init_project.sh` script is used to initialize a new Flutter project. It creates a new Flutter project using `flutter create`, sets up the folder structure for **assets**, **core services**, **extensions**, and **notifications**, and writes necessary dependencies and configurations into the `pubspec.yaml` file. This script solves the problem of manually setting up project directories and configuring dependencies for new Flutter projects.

- Sets up a project structure with folders like **core** (services, theme, utils, notifications, etc.), **assets**, and more.
- Configures necessary dependencies like `hive`, `bloc`, `flutter_gen`, `go_router`, `dio`, and others in the `pubspec.yaml`.
- Populates key files with initial content for error handling, network requests, dependency injection, and more.

Both scripts ensure that best practices are followed from the beginning of development, allowing you to focus on feature implementation rather than setup. They are particularly useful for maintaining a clean and organized project structure without the hassle of manually creating directories and writing repetitive code for every project or feature.

## Contributing

Contributions are welcome! Please create a pull request or submit an issue for discussion.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
