# Deepfake Detector

A Flutter project created as part of my bachelor thesis at Ludwig-Maximilians-Universität München (LMU). The app aims to help users learn about deepfake detection in a playful way.

## What does the app do?

The app shows you two videos - one is real, one is a deepfake. Your challenge is to guess which one is the deepfake! After making your choice, you'll learn if you were right and get an explanation of the telltale signs that gave away the deepfake. You can also track your success rate over time.

## Features

- Compare real videos with deepfakes
- Learn about detection features
- Personal statistics 
- Split-screen comparison view
- Works in browser (Flutter Web)

## Technical Stack

- **Framework**: Flutter Web
- **State Management**: BLoC Pattern with flutter_bloc
- **Video Player**: video_player package
- **Data Storage**: Simple JSON approach
- **Testing**: flutter_test + mockito

## Project Structure

```
lib/
├── main.dart          # Entry point
├── blocs/             # Business logic 
├── models/            # Data models
├── repositories/      # Data access
├── screens/           # UI screens
├── widgets/           # UI components
├── utils/            # Helper functions
└── config/           # Settings
```

## How it works

1. **Start**: Brief introduction
2. **Videos**: Watch two videos
3. **Guess**: Which one is fake?
4. **Feedback**: Learn the solution
5. **Stats**: Track your progress


## Assets

Required folder structure:
```
assets/
├── videos/          # Video files
├── thumbnails/      # Preview images
└── data/           # JSON data
```

---

Developed as part of a bachelor thesis at LMU Munich. While this project aims to help people better recognize deepfakes, it's not a replacement for professional detection tools!
