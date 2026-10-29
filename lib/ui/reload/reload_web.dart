import 'dart:js_interop';

@JS('location')
external _Location get _location;

extension type _Location._(JSObject _) implements JSObject {
  external void reload();
}

/// Reloads the current browser page.
void reloadPage() => _location.reload();
