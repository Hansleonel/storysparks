import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> signInWithApple(String idToken, String accessToken,
      {String? givenName, String? familyName});
  Future<AuthResponse> signInWithGoogle(String idToken, String accessToken);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<Profile> updateProfile(Profile profile);
  Future<Profile?> getProfile(String userId);
  Future<Profile> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? bio,
  });
  Future<void> logout();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  Future<void> _updateUserMetadata(
      {String? givenName, String? familyName}) async {
    if (givenName == null && familyName == null) return;

    String fullName;

    // Si solo tenemos givenName y parece ser un nombre completo (contiene espacio)
    // lo usamos directamente (caso común con Google)
    if (givenName != null && familyName == null && givenName.contains(' ')) {
      fullName = givenName;
    } else {
      // Caso de Apple o cuando tenemos nombre y apellido separados
      fullName = [givenName, familyName].where((e) => e != null).join(' ');
    }

    if (fullName.isEmpty) return;

    try {
      print('Updating user metadata with full_name: $fullName');
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    } catch (error) {
      print('Error updating user metadata: $error');
    }
  }

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Error signing in: $error');
    }
  }

  @override
  Future<AuthResponse> signInWithApple(String idToken, String accessToken,
      {String? givenName, String? familyName}) async {
    try {
      print('Attempting to sign in with Apple...');
      print('ID Token: ${idToken.substring(0, 50)}...');
      print('Access Token: ${accessToken.substring(0, 20)}...');
      print('Given Name: $givenName');
      print('Family Name: $familyName');

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Actualizar metadatos del usuario en auth.users
      await _updateUserMetadata(givenName: givenName, familyName: familyName);

      final user = response.user;
      if (user != null) {
        // Verificar si el usuario ya tiene un perfil
        final existingProfile = await getProfile(user.id);

        if (existingProfile != null) {
          // Si el perfil existe, solo actualizamos lastSignIn manteniendo todos los demás datos
          await updateProfile(Profile(
            id: existingProfile.id,
            username: existingProfile.username,
            fullName: existingProfile.fullName,
            email: existingProfile.email,
            bio: existingProfile.bio,
            provider: existingProfile.provider,
            avatarUrl: existingProfile.avatarUrl,
            createdAt: existingProfile.createdAt,
            updatedAt: DateTime.now(),
            lastSignIn: DateTime.now(),
            storiesGenerated: existingProfile.storiesGenerated,
            storiesShared: existingProfile.storiesShared,
            followersCount: existingProfile.followersCount,
            followingCount: existingProfile.followingCount,
            isPrivate: existingProfile.isPrivate,
            isVerified: existingProfile.isVerified,
          ));
        } else {
          // Si es un nuevo usuario, generamos username y creamos perfil
          final username = await _generateUniqueUsername(
              givenName, familyName, user.email ?? '');

          await updateProfile(Profile(
            id: user.id,
            username: username,
            fullName: [givenName, familyName].where((e) => e != null).join(' '),
            email: user.email,
            provider: 'apple',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastSignIn: DateTime.now(),
          ));
        }
      }

      print('Sign in successful: ${response.user?.email}');
      return response;
    } catch (error) {
      print('Error details: $error');
      if (error is AuthException) {
        print('Status Code: ${error.statusCode}');
        print('Message: ${error.message}');
      }
      throw Exception('Error signing in with Apple: $error');
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle(
      String idToken, String accessToken) async {
    try {
      print('Attempting to sign in with Google...');
      print('ID Token: ${idToken.substring(0, 50)}...');
      print('Access Token: ${accessToken.substring(0, 20)}...');

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        // Obtener información del usuario desde los metadatos
        final userData = user.userMetadata;
        final fullName = userData?['full_name'] as String?;
        final email = user.email;
        final givenName = userData?['name'] as String?;

        // Actualizar metadatos del usuario en auth.users
        await _updateUserMetadata(givenName: givenName);

        // Verificar si el usuario ya tiene un perfil
        final existingProfile = await getProfile(user.id);

        if (existingProfile != null) {
          // Si el perfil existe, solo actualizamos lastSignIn manteniendo todos los demás datos
          await updateProfile(Profile(
            id: existingProfile.id,
            username: existingProfile.username,
            fullName: existingProfile.fullName,
            email: existingProfile.email,
            bio: existingProfile.bio,
            provider: existingProfile.provider,
            avatarUrl: existingProfile.avatarUrl,
            createdAt: existingProfile.createdAt,
            updatedAt: DateTime.now(),
            lastSignIn: DateTime.now(),
            storiesGenerated: existingProfile.storiesGenerated,
            storiesShared: existingProfile.storiesShared,
            followersCount: existingProfile.followersCount,
            followingCount: existingProfile.followingCount,
            isPrivate: existingProfile.isPrivate,
            isVerified: existingProfile.isVerified,
          ));
        } else {
          // Si es un nuevo usuario, generamos username y creamos perfil
          final username =
              await _generateUniqueUsername(givenName, null, email ?? '');

          // Determinar el nombre completo a usar
          String? userFullName;
          if (fullName != null) {
            userFullName = fullName;
          } else if (givenName != null) {
            userFullName = givenName;
          }

          await updateProfile(Profile(
            id: user.id,
            username: username,
            fullName: userFullName,
            email: email,
            provider: 'google',
            avatarUrl: userData?['avatar_url'] as String?,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastSignIn: DateTime.now(),
          ));
        }
      }

      print('Sign in successful: ${response.user?.email}');
      return response;
    } catch (error) {
      print('Error details: $error');
      if (error is AuthException) {
        print('Status Code: ${error.statusCode}');
        print('Message: ${error.message}');
      }
      throw Exception('Error signing in with Google: $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (error) {
      throw Exception('Error signing out: $error');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return supabaseClient.auth.currentUser;
    } catch (error) {
      throw Exception('Error getting current user: $error');
    }
  }

  Future<void> _validateUsername(String username) async {
    print('🔍 Validating username...');

    // Verificar formato
    if (username.length < 3 || username.length > 30) {
      print('❌ Username length invalid');
      throw Exception(
          'El nombre de usuario debe tener entre 3 y 30 caracteres');
    }

    // Solo permitir letras, números y guiones bajos
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegExp.hasMatch(username)) {
      print('❌ Username contains invalid characters');
      throw Exception(
          'El nombre de usuario solo puede contener letras, números y guiones bajos');
    }

    // Verificar si ya existe
    print('🔍 Checking if username is available...');
    final existingUser = await supabaseClient
        .from('profiles')
        .select('username')
        .eq('username', username)
        .maybeSingle();

    if (existingUser != null) {
      print('❌ Username already exists');
      throw Exception('Este nombre de usuario ya está en uso');
    }

    print('✅ Username validation passed');
  }

  void _validatePassword(String password) {
    print('🔍 Validating password...');

    if (password.length < 8) {
      print('❌ Password too short');
      throw Exception('La contraseña debe tener al menos 8 caracteres');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      print('❌ Password missing uppercase letter');
      throw Exception(
          'La contraseña debe contener al menos una letra mayúscula');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      print('❌ Password missing lowercase letter');
      throw Exception(
          'La contraseña debe contener al menos una letra minúscula');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      print('❌ Password missing number');
      throw Exception('La contraseña debe contener al menos un número');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      print('❌ Password missing special character');
      throw Exception(
          'La contraseña debe contener al menos un carácter especial');
    }

    print('✅ Password validation passed');
  }

  @override
  Future<Profile> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? bio,
  }) async {
    try {
      print('📝 Starting user registration process...');
      print('📧 Email: $email');
      print('👤 Username: $username');
      print('📋 Full Name: ${fullName ?? 'Not provided'}');
      print('📖 Bio: ${bio ?? 'Not provided'}');

      // 1. Validaciones iniciales
      print('🔍 Starting validations...');

      // Validar email
      final emailRegExp =
          RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
      if (!emailRegExp.hasMatch(email)) {
        print('❌ Error: Invalid email format');
        throw Exception('El formato del email no es válido');
      }
      print('✅ Email format validation passed');

      // Validar username
      await _validateUsername(username);

      // Validar password
      _validatePassword(password);

      // 2. Sign Up - Crear cuenta en auth.users
      print('🔐 Step 2: Creating user account (Sign Up)...');
      final signUpResponse = await supabaseClient.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (signUpResponse.user == null) {
        print('❌ Error: Failed to create user account in auth.users');
        throw Exception('Error al crear la cuenta de usuario');
      }

      print('✅ User account created successfully');
      print('🆔 User ID: ${signUpResponse.user!.id}');

      // 3. Sign In - Autenticar al usuario
      print('🔑 Step 3: Authenticating user (Sign In)...');
      final signInResponse = await supabaseClient.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (signInResponse.user == null) {
        print('❌ Error: Failed to authenticate after registration');
        throw Exception('Error al autenticar después del registro');
      }

      print('✅ User authenticated successfully');

      // 4. Crear el perfil del usuario
      print('👤 Step 4: Creating user profile...');
      final profile = Profile(
        id: signUpResponse.user!.id,
        username: username,
        fullName: fullName,
        email: email.trim().toLowerCase(),
        bio: bio,
        provider: 'email',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastSignIn: DateTime.now(),
      );

      // 5. Guardar el perfil en la base de datos
      print('💾 Step 5: Saving profile to profiles table...');
      print('🔐 Current auth status: ${supabaseClient.auth.currentUser?.id}');
      final updatedProfile = await updateProfile(profile);
      print('✅ Profile created successfully');
      print('📊 Profile data saved: ${updatedProfile.toString()}');

      return updatedProfile;
    } on AuthException catch (e) {
      print('''
❌ Auth Error Details:
- Message: ${e.message}
- Status Code: ${e.statusCode}
''');
      throw Exception('Error en el registro: ${e.message}');
    } catch (error) {
      print('❌ Error during registration: $error');
      rethrow;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      print('📝 Starting profile update process...');
      print('🎯 Profile ID: ${profile.id}');

      // Verificar si es un registro inicial o una actualización
      final currentUser = supabaseClient.auth.currentUser;
      final isInitialRegistration = currentUser?.id == profile.id;

      print(isInitialRegistration
          ? '🆕 Processing initial profile creation'
          : '📝 Processing profile update');

      print('📊 Profile data to upsert:');
      print('''
        id: ${profile.id}
        username: ${profile.username}
        full_name: ${profile.fullName}
        email: ${profile.email}
        bio: ${profile.bio}
        provider: ${profile.provider}
        last_sign_in: ${profile.lastSignIn?.toIso8601String()}
      ''');

      final data = {
        'id': profile.id,
        'username': profile.username,
        'full_name': profile.fullName,
        'avatar_url': profile.avatarUrl,
        'email': profile.email,
        'bio': profile.bio,
        'provider': profile.provider,
        'last_sign_in': profile.lastSignIn?.toIso8601String(),
        'is_private': profile.isPrivate,
        'is_verified': profile.isVerified,
      };

      print('💾 Attempting to upsert profile data...');
      final response =
          await supabaseClient.from('profiles').upsert(data).select().single();

      print('✅ Profile upsert successful');
      print('📊 Database response: $response');

      final updatedProfile = Profile(
        id: response['id'],
        username: response['username'],
        fullName: response['full_name'],
        avatarUrl: response['avatar_url'],
        email: response['email'],
        bio: response['bio'],
        provider: response['provider'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        lastSignIn: response['last_sign_in'] != null
            ? DateTime.parse(response['last_sign_in'])
            : null,
        storiesGenerated: response['stories_generated'],
        storiesShared: response['stories_shared'],
        followersCount: response['followers_count'],
        followingCount: response['following_count'],
        isPrivate: response['is_private'],
        isVerified: response['is_verified'],
      );

      print('✅ Profile object created from response');
      return updatedProfile;
    } catch (error) {
      print('❌ Error updating profile: $error');
      if (error is PostgrestException) {
        print('''
🚨 PostgrestException Details:
- Message: ${error.message}
- Code: ${error.code}
- Details: ${error.details}
- Hint: ${error.hint}
''');
        if (error.code == '42501') {
          print('''
🔐 RLS (Row Level Security) error:
- Para registro inicial: Verifica que exista una política que permita INSERT cuando auth.uid() coincide con el id del perfil
- Para actualizaciones: Verifica que exista una política que permita UPDATE cuando auth.uid() coincide con el id del perfil
''');
        }
      }
      throw Exception('Error updating profile: $error');
    }
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return Profile(
        id: response['id'],
        username: response['username'],
        fullName: response['full_name'],
        avatarUrl: response['avatar_url'],
        email: response['email'],
        bio: response['bio'],
        provider: response['provider'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        lastSignIn: response['last_sign_in'] != null
            ? DateTime.parse(response['last_sign_in'])
            : null,
        storiesGenerated: response['stories_generated'],
        storiesShared: response['stories_shared'],
        followersCount: response['followers_count'],
        followingCount: response['following_count'],
        isPrivate: response['is_private'],
        isVerified: response['is_verified'],
      );
    } catch (error) {
      throw Exception('Error getting profile: $error');
    }
  }

  Future<String> _generateUniqueUsername(
      String? givenName, String? familyName, String email) async {
    try {
      String baseUsername = '';

      // Intentar crear username del nombre
      if (givenName != null) {
        baseUsername =
            givenName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (familyName != null) {
          baseUsername +=
              familyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        }
      }

      // Si no hay nombre, usar la parte del email antes del @
      if (baseUsername.isEmpty) {
        baseUsername = email.split('@')[0].toLowerCase();
      }

      // Verificar si el username existe
      String username = baseUsername;
      int counter = 1;
      bool exists = true;

      while (exists) {
        final result = await supabaseClient
            .from('profiles')
            .select('username')
            .eq('username', username)
            .maybeSingle();

        if (result == null) {
          exists = false;
        } else {
          username = '$baseUsername$counter';
          counter++;
        }
      }

      return username;
    } catch (error) {
      throw Exception('Error generating unique username: $error');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      print(
          '🔥 AuthRemoteDataSource: Iniciando proceso de eliminación de cuenta');

      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        print('❌ AuthRemoteDataSource: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      print('🔐 AuthRemoteDataSource: Sesión válida, obtenido token de acceso');
      print(
          '🔑 AuthRemoteDataSource: Token JWT presente (exp: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000).toIso8601String()})');
      print('🌐 AuthRemoteDataSource: Llamando a Edge Function delete-user');

      // Aquí es donde se hace la llamada HTTP a la Edge Function
      final edgeFunctionUrl =
          'https://vsmzgwzfmnfwuusahsil.supabase.co/functions/v1/delete-user';
      print(
          '🔗 AuthRemoteDataSource: URL de la Edge Function: $edgeFunctionUrl');

      final stopwatch = Stopwatch()..start();
      final response = await http.delete(
        Uri.parse(edgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      stopwatch.stop();

      print(
          '📡 AuthRemoteDataSource: Respuesta recibida [${response.statusCode}] en ${stopwatch.elapsedMilliseconds}ms');
      print('📊 AuthRemoteDataSource: Headers: ${response.headers}');
      print('📄 AuthRemoteDataSource: Body: ${response.body}');

      if (response.statusCode != 200) {
        print(
            '❌ AuthRemoteDataSource: Error en la respuesta: ${response.body}');
        print(
            '🔍 AuthRemoteDataSource: Código de estado: ${response.statusCode}');

        // Analizar respuesta para dar mensajes más específicos
        if (response.statusCode == 401) {
          print('🔒 AuthRemoteDataSource: Error de autenticación');
          throw Exception('Error de autenticación: No autorizado');
        } else if (response.statusCode == 400) {
          print('⚠️ AuthRemoteDataSource: Error en la solicitud');
          String errorDetails = 'Error al eliminar la cuenta';
          try {
            final responseJson = jsonDecode(response.body);
            if (responseJson['error'] != null) {
              errorDetails = responseJson['error'];
            }
          } catch (e) {
            print('📋 AuthRemoteDataSource: No se pudo decodificar JSON: $e');
          }
          throw Exception(errorDetails);
        } else {
          throw Exception('Error al eliminar la cuenta: ${response.body}');
        }
      }

      print('✅ AuthRemoteDataSource: Cuenta eliminada exitosamente');
    } catch (e) {
      print('💥 AuthRemoteDataSource: Error durante eliminación de cuenta: $e');
      throw Exception('Error al eliminar la cuenta: $e');
    }
  }
}
