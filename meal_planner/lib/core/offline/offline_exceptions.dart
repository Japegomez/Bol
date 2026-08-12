class OfflineEditBlockedException implements Exception {
  OfflineEditBlockedException([
    this.message = 'Sin conexión: la edición en modo hogar requiere conexión',
  ]);

  final String message;

  @override
  String toString() => message;
}

class OfflinePhotoBlockedException implements Exception {
  OfflinePhotoBlockedException([
    this.message =
        'Necesitas conexión para añadir o cambiar la foto de la receta',
  ]);

  final String message;

  @override
  String toString() => message;
}

class OfflinePublicRecipeBlockedException implements Exception {
  OfflinePublicRecipeBlockedException();

  @override
  String toString() => 'OfflinePublicRecipeBlockedException';
}
