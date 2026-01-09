import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:memorysparks/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/domain/repositories/story_repository.dart';

/// Implementación del repositorio de onboarding.
class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _firstTimeKey = 'is_first_time_user';
  static const String _onboardingDataKey = 'onboarding_data';

  final StoryRepository storyRepository;

  OnboardingRepositoryImpl({required this.storyRepository});

  @override
  Future<Either<Failure, bool>> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Si la key no existe, es primera vez (default true)
      final isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
      debugPrint('🎯 OnboardingRepo: isFirstTimeUser = $isFirstTime');
      return Right(isFirstTime);
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error checking first time user: $e');
      return const Left(CacheFailure('Error al verificar si es primera vez'));
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, false);
      debugPrint('✅ OnboardingRepo: Onboarding marcado como completado');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error marking onboarding complete: $e');
      return const Left(CacheFailure('Error al marcar onboarding completado'));
    }
  }

  @override
  Future<Either<Failure, void>> saveOnboardingData(OnboardingData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = {
        'userName': data.userName,
        'memoryText': data.memoryText,
        'selectedImagePath': data.selectedImagePath,
        'imageDescription': data.imageDescription,
        'currentStep': data.currentStep,
        'isCompleted': data.isCompleted,
        // La historia se guarda por separado si existe
        if (data.generatedStory != null) 'storyId': data.generatedStory!.id,
      };
      await prefs.setString(_onboardingDataKey, jsonEncode(jsonData));
      debugPrint('✅ OnboardingRepo: Datos guardados temporalmente');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error saving onboarding data: $e');
      return const Left(CacheFailure('Error al guardar datos del onboarding'));
    }
  }

  @override
  Future<Either<Failure, OnboardingData?>> getOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_onboardingDataKey);

      if (jsonString == null) {
        return const Right(null);
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = OnboardingData(
        userName: jsonData['userName'] ?? '',
        memoryText: jsonData['memoryText'] ?? '',
        selectedImagePath: jsonData['selectedImagePath'],
        imageDescription: jsonData['imageDescription'],
        currentStep: jsonData['currentStep'] ?? 0,
        isCompleted: jsonData['isCompleted'] ?? false,
      );

      debugPrint('✅ OnboardingRepo: Datos recuperados');
      return Right(data);
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error getting onboarding data: $e');
      return const Left(CacheFailure('Error al obtener datos del onboarding'));
    }
  }

  @override
  Future<Either<Failure, void>> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingDataKey);
      debugPrint('✅ OnboardingRepo: Datos temporales limpiados');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error clearing onboarding data: $e');
      return const Left(CacheFailure('Error al limpiar datos del onboarding'));
    }
  }

  @override
  Future<Either<Failure, Story>> transferStoryToUser(
    Story story,
    String userId,
  ) async {
    try {
      debugPrint(
          '🔄 OnboardingRepo: Transfiriendo historia al usuario $userId');

      // Crear una nueva historia con el userId correcto
      final storyWithUser = Story(
        id: story.id,
        userId: userId,
        memory: story.memory,
        genre: story.genre,
        title: story.title,
        content: story.content,
        createdAt: story.createdAt,
        imageUrl: story.imageUrl,
        customImagePath: story.customImagePath,
        rating: story.rating,
        readCount: story.readCount,
        status: 'saved', // Marcar como guardada
        language: story.language,
      );

      // Guardar en el repositorio de historias
      final storyId = await storyRepository.saveStory(storyWithUser);

      debugPrint(
          '✅ OnboardingRepo: Historia transferida exitosamente con ID: $storyId');
      return Right(storyWithUser.copyWith(id: storyId));
    } catch (e) {
      debugPrint('❌ OnboardingRepo: Error transferring story: $e');
      return Left(ServerFailure('Error al transferir la historia: $e'));
    }
  }
}
