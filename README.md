# Flutter Project: Flutter-Bootstrap

This repository includes two Bash scripts, `init_project.sh` and `init_feature.sh`, designed to automate the initialization process for Flutter projects and features within those projects. These scripts follow clean architecture principles and help streamline the setup process, saving time and ensuring consistency across multiple projects.

## Table of Contents
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Code Snippets](#code-snippets)
- [Project Breakdown](#project-breakdown)
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

    sl
    ..registerFactory(() =>
        ${featureNameCapitalized}Bloc(get${featureNameCapitalized}Data: sl()))
    ..registerLazySingleton(() => Get${featureNameCapitalized}Data(repository: sl()))
  

    // AuthenticationHiveDataSource
    ..registerLazySingleton<${featureNameCapitalized}Repository>(() =>
        ${featureNameCapitalized}RepositoryImpl(remoteDataSource: sl(), hiveDataSource: sl()))
    ..registerLazySingleton<${featureNameCapitalized}RemoteDataSource>(
      () => ${featureNameCapitalized}RemoteDataSourceImpl(network: sl()),
    )
       ..registerLazySingleton<${featureNameCapitalized}HiveDataSource>(
      () => ${featureNameCapitalized}HiveDataSourceImpl(),
    )
    ..registerLazySingleton(
        () => Network(baseUrl: UrlConfig.baseUrl, showLog: true));
}
```



## project Breakdown

Here’s a breakdown of the folder structure:

```
[project-name]/
├── application/
│   └── assets/
│       ├── images/
│       └── fonts/
│   └── .env
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── services/
│   │   │   └── injection_container.dart
│   │   ├── storage/
│   │   │   └── hive/
│   │   │       └── hive_service.dart
│   │   ├── theme/
│   │   │   ├── theme.dart
│   │   │   ├── colors.dart
│   │   │   ├── text_styles.dart
│   │   │   └── app_colors.dart
│   │   ├── usecases/
│   │   │   └── usecase.dart
│   │   ├── utils/
│   │   │   ├── typedef.dart
│   │   │   ├── constants.dart
│   │   │   ├── image_util.dart
│   │   │   ├── logger_util.dart
│   │   │   ├── url_launch_services.dart
│   │   │   └── validators.dart
│   │   ├── network/
│   │   │   ├── api_error.dart
│   │   │   ├── api_interceptor.dart
│   │   │   ├── error_interceptor.dart
│   │   │   ├── network_provider.dart
│   │   │   └── network.dart
│   │   ├── notifications/
│   │   │   ├── push_notification.dart
│   │   │   └── notification_service.dart
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   └── custom_text_field.dart
│   │   ├── transitions/
│   │   │   ├── custom_slide_transition.dart
│   │   │   ├── custom_scale_transition.dart
│   │   │   ├── custom_rotation_transition.dart
│   │   │   ├── custom_size_transition.dart
│   │   │   └── custom_fade_slide_transition.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   ├── widget_extensions.dart
│   │   │   └── string_extensions.dart
│   │   ├── routes/
│   │   │   └── routes.dart
│   └── main.dart
├── pubspec.yaml
├── .gitignore
└── README.md
```

## project Breakdown

Here’s a breakdown of the folder structure:

```
[project-name]/
├── lib/
│   ├── core/....
│   ├── features/
│   │   └── [feature-name]/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── [feature-name]_hive_data_source.dart
│   │       │   │   └── [feature-name]_remote_data_source.dart
│   │       │   ├── models/
│   │       │   │   └── [feature-name]_model.dart
│   │       │   └── repositories/
│   │       │       └── [feature-name]_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── [feature-name]_entity.dart
│   │       │   ├── repositories/
│   │       │   │   └── [feature-name]_repository.dart
│   │       │   └── usecases/
│   │       │       └── get_[feature-name]_data.dart
│   │       ├── presentation/
│   │       │   ├── blocs/
│   │       │   │   ├── [feature-name]_state.dart
│   │       │   │   ├── [feature-name]_event.dart
│   │       │   │   └── [feature-name]_bloc.dart
│   │       │   ├── views/
│   │       │   │   └── [feature-name]_page.dart
│   │       │   └── widgets/
│   │       │       └── [feature-name]_widget.dart

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
