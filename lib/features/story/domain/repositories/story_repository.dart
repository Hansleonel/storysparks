import '../entities/story.dart';

abstract class StoryRepository {
  Future<Story> generateStory({
    required String memory,
    required String genre,
    required String userId,
  });
  Future<int> saveStory(Story story);
  Future<List<Story>> getSavedStories(String userId);
  Future<void> updateRating(int storyId, double rating);
  Future<void> deleteStory(int storyId);
  Future<void> incrementReadCount(int storyId);
  Future<List<Story>> getPopularStories(String userId);
  Future<List<Story>> getRecentStories(String userId);
  Future<Story> continueStory({
    required Story previousStory,
    required String userId,
  });
  Future<void> updateStory(Story story);
  Future<Story> getStoryById(int storyId);
}
