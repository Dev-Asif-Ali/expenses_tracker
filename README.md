# Flutter Expenses Tracker App

This Flutter application is an expenses tracker that helps you manage and monitor your daily expenses. The app is built using the BLoC state management pattern and Hive for local data persistence.

## Features

- Add, delete, and view expenses
- Weekly expense summary displayed with a bar graph
- Beautiful splash screen with Lottie animation
- Responsive UI with Flutter
- Persistent data storage using Hive

## Screenshots
![25b10696-bf10-4d5b-a6b4-7edb31c8d148](https://github.com/AsifAli119/expenses_tracker/assets/125544009/c756fa26-b250-402a-bfe0-c389bf6021a1)
![56cbdf40-c4f8-40c4-8ef9-089233b97b2a](https://github.com/AsifAli119/expenses_tracker/assets/125544009/b1e52107-15cc-44f1-8167-1f47423c0936)
![a359a332-da56-4b18-9984-c94d668c36e2](https://github.com/AsifAli119/expenses_tracker/assets/125544009/942cd2bd-a50c-45f6-a5b8-4a4464132c33)
![6ca08cea-9c01-4224-9764-9ed7a6160451](https://github.com/AsifAli119/expenses_tracker/assets/125544009/b2a1ad7e-2c60-417d-8f11-d879a708e037)



## Getting Started

### Prerequisites

- Flutter SDK: [Flutter installation guide](https://flutter.dev/docs/get-started/install)
- Dart SDK: Comes with Flutter
- Hive: No additional installation needed

### Installation

1. Clone the repository:

```sh
git clone [https://github.com/yourusername/expenses_tracker.git](https://github.com/AsifAli119/expenses_tracker)
cd expenses_tracker
```

2. Install dependencies:

```sh
flutter pub get
```

3. Generate the necessary files for Hive:

```sh
flutter packages pub run build_runner build
```

4. Run the app:

```sh
flutter run
```

## Project Structure

```plaintext
lib/
├── core/
│   └── datetime/
│       └── date_time.dart
├── features/
│   └── track_expenses/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── hive_database.dart
│       │   ├── repositories/
│       │   │   └── expenses_repo_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── expenses_item.dart
│       │   ├── repositories/
│       │   │   └── expense_repo.dart
│       │   ├── usecases/
│       │   │   └── add_expense.dart
│       │   │   └── delete_expense.dart
│       │   │   └── get_expenses.dart
│       ├── presentation/
│       │   ├── bloc/
│       │   │   ├── expense_bloc.dart
│       │   │   ├── expense_event.dart
│       │   │   └── expense_state.dart
│       │   ├── pages/
│       │   │   └── home_page.dart
│       │   ├── widgets/
│       │   │   ├── bar_graph.dart
│       │   │   ├── expense_summary.dart
│       │   │   └── expense_tile.dart
│       └── presentation/
│           └── pages/
│               └── home_page.dart
└── main.dart
└── splash_screen.dart
```

## Dependencies

- flutter_bloc: ^8.0.1
- hive: ^2.0.4
- hive_flutter: ^1.1.0
- lottie: ^1.0.1
- fl_chart: ^0.40.0

## Usage

### Adding an Expense

1. Click on the floating action button with the "+" icon.
2. Enter the expense details (name and amount).
3. Click on "Save" to add the expense.

### Deleting an Expense

1. Swipe the expense tile to delete it.

### Viewing the Weekly Summary

1. The summary is displayed on the home screen with a bar graph representing daily expenses.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any bugs or feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [BLoC](https://bloclibrary.dev/#/)
- [Hive](https://docs.hivedb.dev/#/)
- [Lottie](https://lottiefiles.com/)
- [FL Chart](https://github.com/imaNNeoFighT/fl_chart)

---

Feel free to customize this README to better fit your project's needs.
