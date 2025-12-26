# Plan de Revisión de UI y Tema Dark para StorySparks

## Estado de Implementación

### COMPLETADO:
- [x] Sistema de temas (`lib/core/theme/app_theme.dart`)
- [x] ThemeProvider con persistencia (`lib/core/providers/theme_provider.dart`)
- [x] AppColorsExtension para acceso dinámico a colores
- [x] Toggle de Dark Mode en Settings
- [x] HomePage - dark theme + botón paywall temporal eliminado
- [x] LibraryPage - dark theme
- [x] ProfilePage - dark theme
- [x] SettingsPage - dark theme
- [x] MainNavigation - dark theme
- [x] LoginPage - dark theme
- [x] EmptyState widget - dark theme
- [x] ConfirmationDialog widget - dark theme

### PENDIENTE (Páginas secundarias - opcional):
- [ ] GeneratedStoryPage - dark theme
- [ ] AudioPlayerPage - dark theme
- [ ] RegisterPage - dark theme (parcial)
- [ ] PaywallScreen - mantiene diseño de marketing (intencionalmente)

### CÓMO USAR EL DARK MODE:
1. Ir a Settings (icono de engranaje en ProfilePage)
2. En la sección "Preferences", activar el toggle "Dark Mode"
3. El tema se aplica inmediatamente y persiste entre sesiones

---

## Resumen Ejecutivo

Este plan detalla las mejoras de interfaz propuestas (estructura y orden de elementos) para cada página de la aplicación StorySparks, además de la implementación completa del tema dark.

---

## PARTE 1: REVISIÓN DE UI POR PÁGINA

### 1. HomePage (`lib/features/home/presentation/pages/home_page.dart`)

**Estado Actual:** Buena estructura general, widgets bien separados.

**Cambios Propuestos:**
- [ ] **Eliminar `_TemporaryPaywallButton`**: Es un botón de prueba que no debería estar en producción (líneas 984-1029)
- [ ] **Reorganizar sección de imagen**: Mover el preview de imagen seleccionada debajo del TextField en lugar de al lado del botón de selección para mejor uso del espacio
- [ ] **Mejorar contador de palabras**: Posicionarlo más integrado con el TextField

**Nivel de Prioridad:** Media

---

### 2. LibraryPage (`lib/features/library/presentation/pages/library_page.dart`)

**Estado Actual:** Bien estructurada con dos vistas (grid y timeline).

**Cambios Propuestos:**
- [ ] **Consistencia del título**: El título "Library" debería tener el mismo padding que otras páginas (actualmente usa 16, HomePage usa 24)
- [ ] **Mejora en estado vacío**: El EmptyState está bien, pero podría beneficiarse de una imagen o ilustración en lugar de solo un icono
- [ ] **Tarjetas de historia**: Considerar añadir más información visible (fecha, rating) en la vista de grid

**Nivel de Prioridad:** Baja (la estructura está bien)

---

### 3. ProfilePage (`lib/features/profile/presentation/pages/profile_page.dart`)

**Estado Actual:** Buena estructura con tabs para historias y reseñas.

**Cambios Propuestos:**
- [ ] **Mejorar sección de estadísticas**: Añadir separadores visuales entre las estadísticas o usar cards individuales
- [ ] **Tab de Reviews**: Actualmente muestra datos mock (hardcoded). Debería conectarse a datos reales o mostrar un estado vacío apropiado
- [ ] **Botón de settings**: Mover a un AppBar en lugar de solo en la esquina superior derecha

**Nivel de Prioridad:** Media

---

### 4. LoginPage (`lib/features/auth/presentation/pages/login_page.dart`)

**Estado Actual:** Funcional y limpia.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: La página está bien organizada
- [ ] Solo necesita soporte para tema dark (ver Parte 2)

**Nivel de Prioridad:** N/A (sin cambios estructurales)

---

### 5. RegisterPage (`lib/features/auth/presentation/pages/register_page.dart`)

**Estado Actual:** Formulario completo con validaciones.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: Bien estructurada con validaciones apropiadas
- [ ] Solo necesita soporte para tema dark (ver Parte 2)

**Nivel de Prioridad:** N/A (sin cambios estructurales)

---

### 6. SettingsPage (`lib/features/profile/presentation/pages/settings_page.dart`)

**Estado Actual:** Estructura de lista por secciones, clara y navegable.

**Cambios Propuestos:**
- [ ] **Agregar toggle de Dark Mode**: Convertir el item "Theme" en un Switch funcional que active/desactive el tema oscuro (actualmente solo navega a una página inexistente)
- [ ] **Implementar búsqueda de settings**: El buscador existe pero no filtra (línea 331-333 tiene TODO)
- [ ] **Agregar iconos más descriptivos**: Algunos iconos podrían ser más específicos

**Nivel de Prioridad:** Alta (necesario para el tema dark)

---

### 7. GeneratedStoryPage (`lib/features/story/presentation/pages/generated_story_page.dart`)

**Estado Actual:** Excelente estructura con múltiples funcionalidades bien integradas.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: La página está muy bien diseñada
- [ ] Solo necesita soporte para tema dark (ver Parte 2)

**Nivel de Prioridad:** N/A (sin cambios estructurales)

---

### 8. PaywallScreen (`lib/features/subscription/presentation/pages/paywall_screen.dart`)

**Estado Actual:** Diseño premium muy pulido.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: Diseño profesional completo
- [ ] Mantener colores actuales ya que es una pantalla de "marketing"

**Nivel de Prioridad:** N/A (sin cambios)

---

### 9. AudioPlayerPage (`lib/features/audio/presentation/pages/audio_player_page.dart`)

**Estado Actual:** Interfaz de reproductor muy pulida con animaciones.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: Excelente diseño
- [ ] Solo necesita soporte para tema dark (ver Parte 2)

**Nivel de Prioridad:** N/A (sin cambios estructurales)

---

### 10. MainNavigation (`lib/features/navigation/presentation/pages/main_navigation.dart`)

**Estado Actual:** Navegación inferior bien implementada.

**Cambios Propuestos:**
- [ ] **Ningún cambio estructural necesario**: Funcional y limpia
- [ ] Solo necesita soporte para tema dark (ver Parte 2)

**Nivel de Prioridad:** N/A (sin cambios estructurales)

---

## PARTE 2: IMPLEMENTACIÓN DEL TEMA DARK

### Paso 1: Crear Sistema de Temas (`lib/core/theme/app_theme.dart`)

Crear un nuevo archivo que defina los ThemeData para light y dark:

```dart
// Estructura propuesta
class AppTheme {
  static ThemeData get lightTheme => ThemeData(...)
  static ThemeData get darkTheme => ThemeData(...)
}
```

**Tareas:**
- [ ] Crear archivo `app_theme.dart`
- [ ] Definir `lightTheme` con colores actuales
- [ ] Definir `darkTheme` con colores oscuros

---

### Paso 2: Extender AppColors (`lib/core/theme/app_colors.dart`)

Mantener los colores actuales como "light" y agregar versiones dark:

**Paleta Dark Propuesta:**
| Color Light | Color Dark |
|-------------|------------|
| background: #F9FAFB | #121212 |
| white: #FFFFFF | #1E1E1E |
| textPrimary: #1F2937 | #E5E5E5 |
| textSecondary: #6B7280 | #9CA3AF |
| border: #D1D5DB | #374151 |
| primary: #504FF6 | #504FF6 (sin cambio) |
| accent: #A69365 | #A69365 (sin cambio) |

**Tareas:**
- [ ] Crear clase `AppColorsDark` o método que retorne colores según el tema
- [ ] Implementar extensión de BuildContext para acceso fácil a colores

---

### Paso 3: Actualizar SettingsProvider (`lib/features/profile/presentation/providers/settings_provider.dart`)

**Tareas:**
- [ ] Implementar persistencia del estado de dark mode (SharedPreferences)
- [ ] Agregar método `loadSettings()` para cargar preferencia guardada
- [ ] Agregar método `saveSettings()` para guardar preferencia

---

### Paso 4: Actualizar main.dart

**Tareas:**
- [ ] Crear un `ThemeProvider` global o usar el `SettingsProvider` existente
- [ ] Conectar el `MaterialApp` con `theme` y `darkTheme`
- [ ] Usar `themeMode` basado en la preferencia del usuario

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  ...
)
```

---

### Paso 5: Actualizar SettingsPage UI

**Tareas:**
- [ ] Convertir el item "Theme" en un `SwitchListTile` o `_SettingsItemWithSwitch`
- [ ] Conectar el switch con `SettingsProvider.toggleDarkMode()`

---

### Paso 6: Actualizar Widgets para Usar Colores del Tema

Reemplazar referencias directas a `AppColors` con `Theme.of(context)`:

**Archivos a actualizar (principales):**
- [ ] `home_page.dart`
- [ ] `library_page.dart`
- [ ] `profile_page.dart`
- [ ] `login_page.dart`
- [ ] `register_page.dart`
- [ ] `settings_page.dart`
- [ ] `generated_story_page.dart`
- [ ] `audio_player_page.dart`
- [ ] `main_navigation.dart`
- [ ] Widgets en `core/widgets/`
- [ ] Widgets específicos de cada feature

**Patrón de reemplazo:**
```dart
// Antes
backgroundColor: AppColors.background

// Después
backgroundColor: Theme.of(context).scaffoldBackgroundColor
// o usar extensión personalizada
backgroundColor: context.colors.background
```

---

## ORDEN DE IMPLEMENTACIÓN RECOMENDADO

### Fase 1: Fundamentos del Tema Dark
1. Crear `app_theme.dart` con definiciones de tema
2. Crear sistema de colores dinámicos
3. Actualizar `main.dart` para soportar temas
4. Actualizar `SettingsProvider` con persistencia

### Fase 2: UI de Settings
5. Agregar toggle de Dark Mode en SettingsPage
6. Probar que el cambio de tema funciona

### Fase 3: Actualizar Páginas
7. HomePage
8. LibraryPage
9. ProfilePage
10. LoginPage / RegisterPage
11. GeneratedStoryPage
12. AudioPlayerPage

### Fase 4: Mejoras Estructurales de UI
13. Eliminar botón de paywall temporal en HomePage
14. Mejorar sección de estadísticas en ProfilePage
15. Corregir datos mock en Reviews tab

### Fase 5: Widgets Compartidos
16. Actualizar widgets en `core/widgets/`
17. Actualizar diálogos y modales

---

## ARCHIVOS A CREAR

1. `lib/core/theme/app_theme.dart` - Definiciones de ThemeData
2. `lib/core/extensions/theme_extensions.dart` - Extensiones de BuildContext para acceso a colores (opcional pero recomendado)

## ARCHIVOS A MODIFICAR

### Críticos (Tema Dark)
- `lib/main.dart`
- `lib/core/theme/app_colors.dart`
- `lib/features/profile/presentation/providers/settings_provider.dart`
- `lib/features/profile/presentation/pages/settings_page.dart`

### Páginas (actualizar colores)
- Todas las páginas listadas en la Parte 1

### Widgets compartidos
- `lib/core/widgets/loading_lottie.dart`
- `lib/core/widgets/empty_state.dart`
- `lib/core/widgets/confirmation_dialog.dart`

---

## NOTAS ADICIONALES

1. **PaywallScreen**: Se recomienda NO aplicar tema dark ya que es una pantalla de marketing con diseño específico.

2. **Colores de acento**: Los colores `primary` (#504FF6) y `accent` (#A69365) funcionan bien tanto en light como en dark, no requieren cambio.

3. **Animaciones Lottie**: Verificar que las animaciones se vean bien en ambos temas.

4. **Imágenes**: Las portadas de historias e imágenes de perfil no necesitan cambios ya que son contenido del usuario.

5. **Testing**: Probar exhaustivamente en ambos modos antes de considerar completo.
