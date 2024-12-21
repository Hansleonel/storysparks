# StorySparks 📖✨

StorySparks es una aplicación móvil desarrollada en Flutter que transforma recuerdos personales en historias cautivadoras. La aplicación permite a los usuarios compartir sus memorias y convertirlas en narrativas únicas, enriquecidas con elementos visuales y diferentes géneros narrativos.

## 🚀 Características

- **Autenticación de Usuarios**: Sistema de login seguro para mantener las historias personalizadas.
- **Navegación Intuitiva**: Barra de navegación con tres secciones principales:

  - 🏠 Home: Creación de nuevas historias
  - 📚 Biblioteca: Colección de historias generadas
  - 👤 Perfil: Gestión de cuenta y preferencias

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

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gestión de Estado**: Provider
- **Arquitectura**: Clean Architecture
  - Features
  - Presentation Layer
  - Domain Layer
  - Data Layer

## 📱 Compatibilidad

- **iOS**: 11.0 o superior
- **Android**: API 21 (Android 5.0) o superior

## 🎨 Diseño

- **Tema Principal**:

  - Color Primario: `#504FF6`
  - Color de Fondo: `#F9FAFB`
  - Color de Bordes: `#D1D5DB`
  - Texto Primario: `#1F2937`
  - Texto Secundario: `#6B7280`

- **Tipografía**:
  - Principal: Urbanist
  - Títulos Especiales: Playfair

## 📂 Estructura del Proyecto

```
lib/
├── core/
│   ├── theme/
│   │   └── app_colors.dart
│   └── ...
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── providers/
│   │   └── ...
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── providers/
│   │   └── ...
│   ├── library/
│   │   └── presentation/
│   │       └── pages/
│   ├── profile/
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
   git clone [URL_DEL_REPOSITORIO]
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
```

## 🔄 Flujo de la Aplicación

1. **Inicio de Sesión**:

   - Pantalla de login con validación de campos
   - Redirección a la navegación principal tras autenticación exitosa

2. **Navegación Principal**:

   - Bottom Navigation Bar con tres destinos
   - Gestión de estado para la navegación entre páginas

3. **Creación de Historia**:
   - Campo de texto para ingresar el recuerdo
   - Opción para adjuntar imagen
   - Selección de género narrativo
   - Configuración del protagonista
   - Botón de generación (habilitado cuando hay texto)

## 🛡️ Seguridad

- Manejo seguro de datos del usuario
- Validación de entradas
- Gestión segura de archivos multimedia

## 🔜 Próximas Características

- [ ] Integración con IA para generación de historias
- [ ] Compartir historias en redes sociales
- [ ] Modo offline
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
