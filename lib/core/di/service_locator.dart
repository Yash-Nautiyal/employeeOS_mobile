class ServiceLocator {
  static final Map<Type, dynamic> _singletons = {};
  static final Map<Type, Function> _factories = {};

  /// Registers a dependency that is created once and shared across the app.
  static void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Registers a dependency that is newly created every time it is requested.
  static void registerFactory<T>(T Function() factoryFunc) {
    _factories[T] = factoryFunc;
  }

  /// Retrieves the requested dependency.
  static T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw Exception(
        'Dependency $T is not registered in the ServiceLocator. Did you forget to register it?');
  }

  /// Clears all dependencies (useful for logging out or testing)
  static void reset() {
    _singletons.clear();
    _factories.clear();
  }
}

/// A global shorthand to access the ServiceLocator easily, matching industry syntax.
final sl = ServiceLocator.get;
