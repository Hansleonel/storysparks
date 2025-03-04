# StorySparks 📖✨

StorySparks es una aplicación móvil desarrollada en Flutter que transforma recuerdos personales en historias cautivadoras. La aplicación permite a los usuarios compartir sus memorias y convertirlas en narrativas únicas, enriquecidas con elementos visuales y diferentes géneros narrativos.

## 🚀 Características Implementadas

- ✅ **Autenticación de Usuarios**:

  - Sistema de login seguro implementado con AuthProvider y AuthRepository
  - Integración con Sign in with Apple
  - Integración con Google Sign-In
  - Manejo de errores en autenticación con mensajes de usuario
  - Persistencia de sesión
  - Actualización automática de metadatos de usuario
  - Validación de credenciales en tiempo real

- ✅ **Navegación Intuitiva**: Barra de navegación implementada con MainNavigation:

  - 🏠 Home: Creación de nuevas historias
  - 📚 Biblioteca: Colección de historias guardadas
  - 👤 Perfil: Gestión de cuenta y preferencias
  - 🔄 Transiciones fluidas entre pantallas
  - 💾 Persistencia de estado entre navegaciones

- ✅ **Gestión de Historias**:

  - Generación de historias con IA usando Google Generative AI
  - Integración de descripciones de imágenes en la narrativa
  - Procesamiento automático de imágenes para enriquecer historias
  - Guardado local de historias con SQLite
  - Visualización de historias generadas
  - Eliminación de historias
  - Biblioteca personal de historias
  - Sistema de calificación de historias
  - Contador de lecturas por historia
  - Historias populares y recientes
  - Continuación de historias con IA
  - Gestión de estados de historia
  - Sistema de sesiones de chat para continuaciones coherentes
  - Limpieza automática de borradores antiguos
  - Marcado de historias como eliminadas (soft delete)
  - Optimización de almacenamiento de imágenes
  - Análisis semántico de imágenes con IA

- ✅ **Sistema de Suscripción**:

  - Planes de suscripción flexibles:
    - Plan Semanal ($3.99)
    - Plan Mensual ($9.99)
    - Plan Anual ($59.99)
  - Beneficios por nivel:
    - Historias ilimitadas
    - Sin publicidad
    - Edición de personajes
    - Continuación de historias
    - Acceso anticipado (planes mensual y anual)
    - Soporte prioritario (plan anual)
  - Interfaz de pago moderna y atractiva
  - Cálculo automático de ahorros por plan
  - Período de prueba gratuito
  - Gestión de beneficios por tipo de suscripción

- ✅ **Creación de Historias**:

  - Campo de texto para compartir recuerdos
  - Sistema avanzado de procesamiento de imágenes:
    - Soporte para múltiples formatos (JPEG, PNG, WEBP, HEIC)
    - Análisis automático de imágenes con IA
    - Integración de descripciones visuales en la narrativa
    - Validación de tamaño y formato de imágenes
    - Compresión inteligente de imágenes
    - Redimensionamiento adaptativo
    - Generación de nombres únicos para archivos
  - Selección de géneros narrativos:
    - Feliz
    - Nostálgico
    - Aventura
    - Familiar
    - Divertido
  - Personalización del protagonista

- ✅ **Modo Offline**:

  - Almacenamiento local de historias generadas
  - Acceso a historias guardadas sin conexión
  - Sincronización automática cuando se restablece la conexión
  - Gestión eficiente del almacenamiento local

- ✅ **Internacionalización**:
  - Soporte multiidioma (Español e Inglés)
  - Localización de textos y mensajes
  - Adaptación de contenido según región

## 🛠️ Tecnologías Implementadas

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gestión de Estado**: Provider
- **Backend y Autenticación**:
  - Supabase para autenticación y almacenamiento
  - Sign in with Apple integration
  - Google Sign-In integration
  - Gestión segura de tokens
- **Arquitectura**: Clean Architecture implementada con:
  - Presentation Layer (providers, pages)
  - Domain Layer (usecases, repositories)
  - Data Layer (datasources, repositories implementations)
  - Managers para gestión de sesiones de chat con Google Generative AI
  - Principios SOLID aplicados
- **Almacenamiento Local**:
  - SQLite con sqflite
  - Gestión eficiente de consultas
  - Optimización de transacciones
- **IA**:
  - Google Generative AI para generación de historias
  - Procesamiento de imágenes y generación de descripciones
  - Gestión de sesiones de chat para continuidad narrativa
  - Análisis semántico de contenido visual
- **Networking**:
  - Dio para peticiones HTTP
  - Manejo de timeouts y reintentos
  - Interceptores personalizados
- **Inyección de Dependencias**:
  - GetIt + Injectable
  - Configuración modular
- **Manejo de Errores**:
  - Dartz para Result Types
  - Sistema de logging detallado
  - Manejo de errores por capa
  - Feedback visual al usuario
- **Gestión de Assets**:
  - SVG Support (flutter_svg)
  - Audio (just_audio)
  - Image Picker con soporte multiformat
  - Animaciones personalizadas
  - Optimización de carga de recursos
- **Monetización**:
  - Sistema de suscripciones in-app
  - Gestión de planes y beneficios
  - Cálculo de descuentos

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
│   │   │   ├── managers/
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
   - API Key de Google Generative AI

2. **Instalación**:

   ```bash
   git clone https://github.com/Hansleonel/storysparks
   cd storysparks
   flutter pub get
   ```

3. **Configuración de Variables de Entorno**:
   Crea un archivo `.env` en la raíz del proyecto:

   ```
   GEMINI_API_KEY=tu_api_key_aqui
   SUPABASE_URL=tu_url_de_supabase
   SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
   GOOGLE_WEB_CLIENT_ID=tu_web_client_id.apps.googleusercontent.com
   GOOGLE_IOS_CLIENT_ID=tu_ios_client_id.apps.googleusercontent.com
   ```

   Para obtener los IDs de cliente de Google:

   - Ve a la [Consola de Google Cloud](https://console.cloud.google.com/)
   - Selecciona tu proyecto o crea uno nuevo
   - Ve a "APIs y servicios" > "Credenciales"
   - Crea o edita un ID de cliente OAuth 2.0
   - Configura los orígenes autorizados y las URIs de redirección
   - Copia los IDs de cliente para Web e iOS

   Además, para iOS, actualiza el archivo `ios/Runner/Info.plist` con el esquema URL de Google:

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.TU_IOS_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

4. **Ejecutar el Proyecto**:
   ```bash
   flutter run
   ```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  dio: ^5.4.0
  sqflite: ^2.3.0
  flutter_svg: ^2.0.9
  just_audio: ^0.9.36
  image_picker: ^1.0.4
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  injectable: ^2.3.2
  google_generative_ai: ^0.3.3
  flutter_dotenv: ^5.1.0
  flutter_rating_bar: ^4.0.1
  sign_in_with_apple: ^6.1.4
  google_sign_in: ^6.2.2
  supabase_flutter: ^2.8.3
  mime: ^1.0.6
```

## 🔄 Flujo de la Aplicación Implementado

1. **Inicio de Sesión**:

   - ✅ Autenticación implementada con AuthProvider y AuthRepository
   - ✅ Integración con Sign in with Apple
   - ✅ Integración con Google Sign-In
   - ✅ Manejo de errores y feedback al usuario
   - ✅ Redirección a la navegación principal tras autenticación exitosa

2. **Navegación Principal**:

   - ✅ Bottom Navigation Bar implementado con MainNavigation
   - ✅ Gestión de estado para la navegación entre páginas

3. **Gestión de Historias**:

   - ✅ Generación de historias con StoryProvider
   - ✅ Procesamiento y análisis de imágenes
   - ✅ Sistema de continuación de historias con contexto
   - ✅ Almacenamiento local de historias con estados
   - ✅ Visualización animada de historias
   - ✅ Sistema de calificación interactivo
   - ✅ Contador de lecturas automático
   - ✅ Limpieza automática de borradores antiguos
   - ✅ Gestión de historias populares y recientes

## 🛡️ Seguridad

- ✅ Implementación de autenticación segura
- ✅ Almacenamiento local seguro de historias
- ✅ Validación de entradas de usuario
- ✅ Gestión segura de API keys
- ✅ Manejo de sesiones de chat encapsulado
- ✅ Validación de imágenes y archivos
- ✅ Protección de datos sensibles con variables de entorno
- ✅ Sanitización de entradas de usuario
- ✅ Prevención de inyección SQL
- ✅ Manejo seguro de tokens de autenticación
- ✅ Verificación de integridad de datos

## 🔜 Próximas Características

- [x] Integración con IA para generación de historias
- [x] Modo offline con almacenamiento local
- [x] Múltiples idiomas
- [x] Sistema de continuación de historias
- [x] Procesamiento de imágenes con IA
- [ ] Compartir historias en redes sociales
- [ ] Temas personalizables
- [ ] Exportación de historias en diferentes formatos
- [ ] Generación de audiolibros
- [ ] Personalización avanzada de portadas

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
