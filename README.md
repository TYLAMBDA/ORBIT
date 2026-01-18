# Orbital Reader

Orbital Reader is a comprehensive Sci-Fi book catalog and reader application, allowing users to explore the "Galactic Archives" and read public domain classics.

## Architecture

The project follows a clean segregation of duties, consisting of two main components:

- **Frontend**: A [Flutter](https://flutter.dev/) application located in `orbital-reader-flutter`. It provides a modern, glassmorphic user interface optimized for cross-platform deployment.
- **Backend**: A [.NET 8 Web API](https://dotnet.microsoft.com/) located in `orbital-reader-backend`. It follows Domain-Driven Design (DDD) and Clean Architecture principles, organized into `Api`, `Application`, `Core`, and `Infrastructure` layers.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

### Backend Setup

1.  Navigate to the API directory:
    ```bash
    cd orbital-reader-backend/OrbitalReader.Api
    ```
2.  Run the application:
    ```bash
    dotnet run
    ```
    The API will start (default: `http://localhost:5000`).

### Frontend Setup

1.  Navigate to the Flutter directory:
    ```bash
    cd orbital-reader-flutter
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

## Key Features

- **Galactic Archives**: Browse a curated list of Sci-Fi books.
- **Library Management**: "Acquire" books to add them to your personal collection.
- **Modern UI**: Implements `GlassCard` and `CyberButton` components for a futuristic look.
