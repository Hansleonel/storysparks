import '../entities/story.dart';

abstract class StoryRepository {
  Future<Story> generateStory({
    required String memory,
    required String genre,
    required String userId,
    String? imageDescription,
  });

  Future<String> getImageDescription(String imagePath);

  Future<Story> continueStory(Story story);

  Future<int> saveStory(Story story);
  Future<void> updateStoryStatus(int storyId, String status);
  Future<List<Story>> getSavedStories(String userId);
  Future<void> updateRating(int storyId, double rating);
  Future<void> deleteStory(int storyId);
  Future<void> incrementReadCount(int storyId);
  Future<List<Story>> getPopularStories(String userId);
  Future<List<Story>> getRecentStories(String userId);
  Future<void> cleanupOldDraftStories();
}
