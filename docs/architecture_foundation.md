# Architecture Foundation

This project uses a feature-oriented layered architecture:

- `presentation` depends only on controllers, view-models, and use cases.
- `application` orchestrates scenarios through domain interfaces.
- `domain` contains entities and repository contracts.
- `data` and `infrastructure` implement contracts through Dio, local storage, or plugin bridges.
- `core` contains only shared technical concerns such as config, errors, logging, network, permissions, and utilities.

## Dependency Rules

- UI must not access `Dio`, `Geolocator`, `FlutterSecureStorage`, or plugin instances directly.
- All external dependencies are registered in `AppDependencies`.
- Repository contracts use the `*Repository` suffix.
- Repository implementations use the `*RepositoryImpl` suffix.
- Application scenarios use the `*UseCase` suffix.
- Domain and storage models use the `*Entity` suffix.
- `*Controller` classes belong only to the presentation layer.

## Migration Path

- Existing auth, judge, and participant flows can keep their current screens.
- Controllers should gradually stop depending on raw remote data sources.
- New production features should start in their target modules instead of growing inside existing UI controllers.
- Tracking, sync, local storage, sensor bridge, race computer, export, and sensor fusion are scaffolded so later steps can land in prepared extension points.
