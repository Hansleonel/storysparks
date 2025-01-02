# StorySparks 📖✨

StorySparks es una aplicación móvil desarrollada en Flutter que transforma recuerdos personales en historias cautivadoras. La aplicación permite a los usuarios compartir sus memorias y convertirlas en narrativas únicas, enriquecidas con elementos visuales y diferentes géneros narrativos.

## 🚀 Características Implementadas

- ✅ **Autenticación de Usuarios**: Sistema de login seguro implementado con AuthProvider y AuthRepository.
- ✅ **Navegación Intuitiva**: Barra de navegación implementada con MainNavigation:

  - 🏠 Home: Creación de nuevas historias
  - 📚 Biblioteca: Colección de historias guardadas
  - 👤 Perfil: Gestión de cuenta y preferencias

- ✅ **Gestión de Historias**:

  - Generación de historias con StoryProvider
  - Guardado local de historias
  - Visualización de historias generadas
  - Eliminación de historias
  - Biblioteca personal de historias

- **Creación de Historias**:
  - Campo de texto para compartir recuerdos
  - Soporte para añadir imágenes (galería o cámara)
  - Selección de géneros narrativos:
    - Feliz
    - Nostálgico
    - Aventura
    - Familiar
    - Divertido
  - Personalización del protagonista

## 🛠️ Tecnologías Implementadas

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gestión de Estado**: Provider
- **Arquitectura**: Clean Architecture implementada con:
  - Presentation Layer (providers, pages)
  - Domain Layer (usecases, repositories)
  - Data Layer (datasources, repositories implementations)
- **Almacenamiento Local**: Implementado para historias

## 📂 Estructura del Proyecto Actual

```
lib/
├── core/
│   ├── theme/
│   │   └── app_colors.dart
│   ├── dependency_injection/
│   │   └── service_locator.dart
│   └── routes/
│       └── app_routes.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   ├── story/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   ├── home/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── pages/
│   ├── library/
│   │   └── presentation/
│   │       └── pages/
│   └── navigation/
│       └── presentation/
│           └── pages/
└── main.dart
```

## 🔧 Configuración del Proyecto

1. **Requisitos Previos**:

   - Flutter SDK
   - Dart SDK
   - Android Studio / Xcode

2. **Instalación**:

   ```bash
   git clone https://github.com/Hansleonel/storysparks
   cd storysparks
   flutter pub get
   ```

3. **Ejecutar el Proyecto**:
   ```bash
   flutter run
   ```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  image_picker: ^1.0.4
  # Inyección de dependencias
  get_it: ^7.6.4
```

## 🔄 Flujo de la Aplicación Implementado

1. **Inicio de Sesión**:

   - ✅ Autenticación implementada con AuthProvider y AuthRepository
   - ✅ Redirección a la navegación principal tras autenticación exitosa

2. **Navegación Principal**:

   - ✅ Bottom Navigation Bar implementado con MainNavigation
   - ✅ Gestión de estado para la navegación entre páginas

3. **Gestión de Historias**:

   - ✅ Generación de historias con StoryProvider
   - ✅ Almacenamiento local de historias
   - ✅ Visualización de historias en la biblioteca
   - ✅ Eliminación de historias guardadas

## 🛡️ Seguridad

- ✅ Implementación de autenticación segura
- ✅ Almacenamiento local seguro de historias
- ✅ Validación de entradas de usuario

## 🔜 Próximas Características

- [x] Integración con IA para generación de historias
- [ ] Compartir historias en redes sociales
- [x] Modo offline con almacenamiento local
- [ ] Temas personalizables
- [ ] Múltiples idiomas

## 👥 Contribución

Las contribuciones son bienvenidas. Por favor, sigue estos pasos:

1. Fork el proyecto
2. Crea una rama para tu característica
3. Realiza tus cambios
4. Envía un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para más detalles.

## 📞 Contacto

Para preguntas o sugerencias, por favor abre un issue en el repositorio.

---

Desarrollado con ❤️ usando Flutter
