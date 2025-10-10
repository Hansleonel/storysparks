# StorySparks 📖✨

StorySparks es una aplicación móvil desarrollada en Flutter que transforma recuerdos personales en historias cautivadoras. La aplicación permite a los usuarios compartir sus memorias y convertirlas en narrativas únicas, enriquecidas con elementos visuales y diferentes géneros narrativos.

## 🚀 Características Implementadas

- ✅ **Autenticación de Usuarios**:

  - Sistema de login seguro con AuthProvider y AuthRepository
  - Integración con Sign in with Apple y Google Sign-In
  - Manejo avanzado de errores y feedback al usuario
  - Persistencia de sesión y actualización automática de metadatos
  - Validación de credenciales en tiempo real

- ✅ **Navegación Intuitiva**:

  - Barra de navegación inferior (MainNavigation) con Home, Biblioteca y Perfil
  - Transiciones fluidas y persistencia de estado entre pantallas
  - Soporte para múltiples vistas en la biblioteca: grid y timeline

- ✅ **Gestión de Historias**:

  - Generación de historias con IA (Google Generative AI)
  - Integración de descripciones de imágenes en la narrativa
  - Procesamiento automático y optimizado de imágenes (compresión, redimensionamiento, validación de formato y tamaño)
  - Guardado local de historias con SQLite y gestión eficiente de almacenamiento
  - Visualización animada de historias y sistema de calificación interactivo
  - Eliminación y soft delete de historias
  - Biblioteca personal con historias populares y recientes
  - Contador de lecturas automático y gestión de estados de historia
  - Continuación de historias con IA y sesiones de chat coherentes
  - Limpieza automática de borradores antiguos
  - Análisis semántico de imágenes con IA

- ✅ **Sistema de Suscripción Premium (RevenueCat)**:

  - Integración completa con RevenueCat para manejo de suscripciones in-app
  - Planes flexibles: Semanal, Mensual, Anual con descuentos automáticos
  - Beneficios por nivel: historias ilimitadas, sin publicidad, edición de personajes, continuación de historias, acceso anticipado, soporte prioritario
  - Interfaz de pago moderna y atractiva (PaywallScreen) con Apple App Store compliance
  - PremiumGate widget para controlar acceso a funciones premium
  - Sincronización automática con backend (Supabase) del estado premium
  - Gestión de beneficios y control de acceso según suscripción
  - Restauración automática de compras y manejo de errores robusto
  - Integración automática con sistema de autenticación existente

- ✅ **Creación y Personalización de Historias**:

  - Campo de texto para compartir recuerdos
  - Procesamiento avanzado de imágenes (JPEG, PNG, WEBP, HEIC)
  - Análisis automático de imágenes y generación de descripciones visuales
  - Personalización básica de portadas mediante selección de imagen propia
  - Selección de géneros narrativos: Feliz, Nostálgico, Aventura, Familiar, Divertido
  - Personalización del protagonista (estructura lista para expansión)

- ✅ **Modo Offline**:

  - Almacenamiento local y acceso sin conexión a historias
  - Sincronización automática al recuperar conexión
  - Gestión eficiente del almacenamiento local

- ✅ **Internacionalización y Accesibilidad**:

  - Soporte multiidioma (Español e Inglés)
  - Localización de textos y mensajes
  - Adaptación de contenido según región

- ✅ **Exportación y Compartir**:

  - Generación de cartas PDF hermosas y elegantes con diseño temático por género
  - Servicio de compartir integrado (ShareService) para redes sociales y mensajería
  - PDFs con branding de la app, fuentes personalizadas y diseño profesional
  - Exportación de historias en formato carta con metadata y ratings
  - Temas visuales específicos por género (Romance, Aventura, Misterio, Fantasía)

- ✅ **Gestión de Perfil y Configuraciones**:

  - Página de perfil completa con información del usuario
  - Sistema de configuraciones avanzado (SettingsProvider)
  - Gestión de preferencias de idioma y tema
  - Eliminación segura de cuenta con Edge Function en Supabase
  - Visualización de estadísticas de historias del usuario

- ✅ **Otras funcionalidades destacadas**:
  - Vista de biblioteca en grid y timeline
  - Limpieza automática de borradores antiguos
  - Gestión de historias populares y recientes
  - Calificación de historias
  - Gestión de imágenes personalizadas para portadas
  - Indicador de nuevas historias (NewStoryIndicatorProvider)
  - Animaciones Lottie para estados de carga
  - Splash screen personalizado para iOS

## 🛠️ Tecnologías Implementadas

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gestión de Estado**: Provider
- **Backend y Autenticación**:
  - Supabase para autenticación, almacenamiento y backend
  - Sign in with Apple integration
  - Google Sign-In integration
  - Gestión segura de tokens
  - Edge Functions para operaciones backend (eliminación de cuentas)
  - Sincronización automática de estado premium con backend
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
  - Animaciones Lottie para estados de carga
  - Fuentes personalizadas (Playfair Display, Urbanist)
  - Optimización de carga de recursos
- **Exportación y Documentos**:
  - Generación de PDFs elegantes con pdf package
  - Servicio de compartir multiplataforma (share_plus)
  - Temas visuales personalizados por género
  - Cartas hermosas con branding y metadata
- **Monetización**:
  - RevenueCat SDK para suscripciones in-app multiplataforma
  - Sistema de suscripciones con Clean Architecture
  - Gestión de planes y beneficios con entitlements
  - Cálculo automático de descuentos y savings
  - Apple App Store compliance para paywalls
  - Restauración automática de compras
  - Sincronización bidireccional con backend

## 📂 Estructura del Proyecto Actual

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── genre_constants.dart
│   │   └── revenuecat_constants.dart
│   ├── dependency_injection/
│   │   └── service_locator.dart
│   ├── providers/
│   │   └── new_story_indicator_provider.dart
│   ├── routes/
│   │   └── app_routes.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── pdf_letter_service.dart
│   │   └── share_service.dart
│   ├── theme/
│   │   └── app_colors.dart
│   ├── utils/
│   │   ├── cover_image_helper.dart
│   │   ├── date_formatter.dart
│   │   └── modal_utils.dart
│   └── widgets/
│       ├── empty_state.dart
│       ├── loading_lottie.dart
│       └── lottie_animation.dart
├── examples/
│   ├── pdf_example.dart
│   └── revenuecat_example.dart
├── features/
│   ├── auth/
│   │   ├── data/, domain/, presentation/
│   │   └── usecases/ (login, register, apple/google signin, delete account)
│   ├── home/
│   │   ├── domain/usecases/
│   │   └── presentation/
│   ├── library/
│   │   └── presentation/
│   ├── navigation/
│   │   └── presentation/
│   ├── profile/
│   │   ├── data/, domain/, presentation/
│   │   └── pages/ (profile, settings)
│   ├── story/
│   │   ├── data/ (datasources, managers, services)
│   │   ├── domain/ (entities, repositories, usecases)
│   │   └── presentation/ (providers, pages, widgets)
│   └── subscription/
│       ├── data/ (revenuecat datasource, models)
│       ├── domain/ (entities, repositories, usecases)
│       └── presentation/ (paywall, premium gate, providers)
├── l10n/
│   ├── app_en.arb
│   └── app_es.arb
└── main.dart
```

## 🔧 Configuración del Proyecto

1. **Requisitos Previos**:

   - Flutter SDK
   - Dart SDK
   - Android Studio / Xcode
   - API Key de Google Generative AI
   - Cuenta de RevenueCat (para suscripciones)
   - Proyecto de Supabase configurado

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
   SUPABASE_SERVICE_ROLE_KEY=tu_service_role_key_de_supabase
   GOOGLE_WEB_CLIENT_ID=tu_web_client_id.apps.googleusercontent.com
   GOOGLE_IOS_CLIENT_ID=tu_ios_client_id.apps.googleusercontent.com
   REVENUECAT_API_KEY=tu_revenuecat_api_key
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

   Para RevenueCat, configura también el archivo `ios/Runner/Products.storekit` para testing local de suscripciones.

4. **Configuración de Supabase (Backend)**:

   El proyecto incluye configuración completa de Supabase con:

   - Edge Functions para operaciones backend
   - Configuración local en `supabase/config.toml`
   - Function de eliminación de cuenta en `supabase/functions/delete-user/`

5. **Ejecutar el Proyecto**:

   ```bash
   flutter run
   ```

   Para desarrollo local con Supabase:

   ```bash
   supabase start
   flutter run
   ```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  cupertino_icons: ^1.0.2

  # State Management
  provider: ^6.1.1

  # Network
  dio: ^5.4.0

  # Local Storage
  sqflite: ^2.3.0
  path: ^1.8.3

  # UI Components
  flutter_svg: ^2.0.9
  flutter_rating_bar: ^4.0.1
  lottie: ^3.2.0

  # Media
  just_audio: ^0.9.36
  image_picker: ^1.0.4
  image: ^4.1.7

  # Utils
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  injectable: ^2.3.2
  google_generative_ai: ^0.3.0
  flutter_dotenv: ^5.1.0
  mime: ^1.0.4
  uuid: ^4.3.3
  path_provider: ^2.1.2
  url_launcher: ^6.2.2

  # Auth
  sign_in_with_apple: ^6.1.4
  google_sign_in: ^6.2.2
  supabase_flutter: ^2.9.0
  shared_preferences: ^2.3.5

  # Sharing & Export
  share_plus: ^7.2.2
  pdf: ^3.10.7
  printing: ^5.12.0

  # Monetization
  purchases_flutter: ^8.8.0
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

4. **Sistema de Suscripciones**:

   - ✅ Integración completa con RevenueCat
   - ✅ Paywall conforme a Apple App Store guidelines
   - ✅ PremiumGate para control de acceso a funciones
   - ✅ Sincronización automática con backend
   - ✅ Restauración de compras y manejo de errores

5. **Exportación y Compartir**:

   - ✅ Generación de cartas PDF elegantes
   - ✅ Compartir historias en múltiples formatos
   - ✅ Temas visuales personalizados por género
   - ✅ Integración con ShareService nativo

6. **Gestión de Perfil**:

   - ✅ Página de perfil con estadísticas de usuario
   - ✅ Configuraciones avanzadas y preferencias
   - ✅ Eliminación segura de cuenta con Edge Function

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
- ✅ Edge Functions seguras con verificación JWT
- ✅ Eliminación segura de datos con stored procedures
- ✅ Gestión segura de suscripciones con RevenueCat
- ✅ Protección de API keys y configuración sensible

## 🏗️ Arquitectura Backend (Supabase)

El proyecto incluye una arquitectura backend completa:

### Edge Functions

- **delete-user**: Función para eliminación segura de cuentas de usuario
  - Limpieza completa de datos relacionados
  - Verificación JWT automática
  - Stored procedures para integridad referencial

### Configuración Local

- Desarrollo local con `supabase/config.toml`
- Configuración de servicios: Auth, Storage, Realtime, Analytics
- Variables de entorno seguras

## 🔧 Configuración de RevenueCat

Para configurar las suscripciones in-app:

1. **RevenueCat Dashboard**:

   - API Key: `appl_iUnkmztHtYheiyGRCengKTwiPja`
   - Entitlement ID: `Memory Sparks Subscriptions`

2. **App Store Connect**:

   - Configura productos de suscripción (Semanal, Mensual, Anual)
   - Asocia los productos con RevenueCat

3. **Configuración en código**:
   - Actualiza `lib/core/constants/revenuecat_constants.dart`
   - Agrega la API key a las variables de entorno

## 📄 Documentación Adicional

- **RevenueCat Implementation**: Ver `REVENUECAT_IMPLEMENTATION.md` para detalles completos
- **PDF Examples**: Ver `lib/examples/pdf_example.dart` para uso de generación de PDFs
- **RevenueCat Examples**: Ver `lib/examples/revenuecat_example.dart` para implementación de suscripciones

## 🔜 Próximas Características y Mejoras

- [ ] **Temas personalizables (oscuro/claro)** _(estructura en settings, pendiente implementación)_
- [ ] **Generación de audiolibros** _(botón en UI, pendiente implementación)_
- [ ] **Personalización avanzada de portadas** _(actualmente solo selección de imagen, edición avanzada pendiente)_
- [ ] **Análisis de uso y métricas** _(estructura preparada)_
- [ ] **Notificaciones push** _(estructura en settings)_
- [ ] **Sincronización en la nube** _(backend preparado)_

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
