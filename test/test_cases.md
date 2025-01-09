# Test cases for:
- video_repository_test
- statistics_repository_test
- user_repository_test

- game_bloc_test

## video_repository:
### initializiation group
- load videos on initialization
- throw VideoException when no videos available
- only initialize once
### getRandomVideoPair group
- should initialize repository if not initialized
- returns one real and one fake video
- should throw when no real or no fake videos are available
### getVideoById group
- should initialize repository if not initialized
- return correct video for existing id
- throw exception for non-existing id


