# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
必ず日本語でチャットしてください。

## Project Overview

This is a SwiftUI-based iOS application for learning multiplication tables (九九/times tables) in Japanese. The app uses SwiftData for persistence and follows MVVM architecture patterns.

## Build and Development Commands

```bash
# Build the project
xcodebuild -scheme TimesTablesApp -configuration Debug -project TimesTablesApp/TimesTablesApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -allowProvisioningUpdates build | xcbeautify

# Run tests
xcodebuild -scheme TimesTablesApp -configuration Debug -workspace TimesTablesApp/TimesTablesApp.xcodeproj/project.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -destination-timeout 60 -only-testing:TimesTablesAppTests test -verbose | xcbeautify

# Clean build
xcodebuild -scheme TimesTablesApp clean

# Build for release
xcodebuild -scheme TimesTablesApp -configuration Release build
```

## Architecture

### SVVS (Store-View-ViewState) Pattern
- Views trigger actions through ViewState
- ViewState communicates with Store (singleton data layer)
- Store handles API/DB operations and maintains app state
- Data changes flow back to View through ViewState (unidirectional data flow)

### Key Components
- **Models/** - SwiftData models for persistence (UserPoints, DifficultQuestion, AnswerTimeRecord, etc.)
- **Views/** - SwiftUI views (MultiplicationView, StatsView, ParentDashboardView)
- **ViewStates/** - State management classes (requires @MainActor for tests)
- **Resources/** - Audio files for feedback sounds

## Development Requirements

### Testing
- Use swift-testing framework (not XCTest)
- ViewState tests are mandatory and require @MainActor
- Test execution may not complete properly in agent mode - request manual execution if needed

### Localization
- Primary language: Japanese
- English support required for all new text
- Edit Localizable.xcstrings only when explicitly requested
- Japanese text should use only kanji taught up to 2nd grade elementary school

### Code Standards
- Add SwiftDoc comments for complex functions
- Ensure all code compiles without errors
- Follow existing patterns when adding new components
- The main entry point is TimesTablesAppApp.swift (@main)

### Dependencies
- Firebase (Analytics, Performance)
- SwiftData for persistence
- AVFoundation for audio
- Sound effects credited to OtoLogic

## PR Format

```
## 概要

## 変更内容

## レビュアーへの補足情報

## 手動でテストが必要な箇所(チェックボックス有りで最大10個)
```

## Current Features
1. Quiz modes: Random, Sequential (段ごと), Fill-in-blank (虫食い)
2. Point system with earning/spending tracking
3. Parent dashboard with PIN protection
4. Learning statistics and analytics
5. Sound feedback and animations
6. Difficulty tracking and adaptive learning
7. **Phase 2A Features (2025-07-13)**:
   - Progress visualization (九九マスターマップ, mastery levels)
   - Daily challenges with streak tracking
   - Parent-child communication (text/voice messages)
   - Localization support (Japanese/English)
8. **Phase 2B Features (2025-07-17)**:
   - Gamification level system (Lv.1-50 with experience points)
   - Title system with 7 different titles (九九みならい → 九九レジェンド)
   - Level up animations and progress visualization
   - Bonus experience for difficult problems

## Development Lessons Learned (2025-07-13)

### SwiftData Best Practices
- **Property Naming**: Avoid reserved words like `description` - use descriptive alternatives like `achievementDescription`
- **Initialization Order**: Initialize all stored properties before setting computed/derived properties
- **Model Relationships**: Use UUID-based relationships rather than direct object references for better data integrity

### SVVS Pattern Implementation
- **ViewState Design**: Always mark ViewState classes with @MainActor for UI thread safety
- **Data Flow**: Maintain unidirectional data flow from ViewState → Store → Model
- **Error Handling**: Implement comprehensive error handling in ViewState methods

### Localization Strategy
- **NSLocalizedString Usage**: Apply to all user-facing strings in ViewState and Model layers
- **String Management**: Organize Localizable.xcstrings with clear comments for context
- **Testing**: Verify localization works across all supported languages before deployment

### UI/UX Optimization
- **Layout Efficiency**: Prioritize frequently-used actions at top of scrollable views
- **Compact Design**: Use minimal spacing and smaller components for child-friendly interfaces
- **Accessibility**: Consider VoiceOver and other accessibility features from initial design phase

## Development Lessons Learned (2025-07-17)

### Level System Implementation
- **Data Initialization**: Use lazy evaluation for ViewState properties to avoid initialization timing issues
- **Localization Strategy**: Always use dynamic title generation (`getTitleForLevel`) rather than stored database values for multi-language support
- **UI State Management**: Implement explicit `objectWillChange.send()` calls for reliable UI updates in complex data flows
- **Experience Calculation**: Use quadratic curves (5*level² + 5*level - 10) for balanced progression that maintains engagement

### SwiftData Performance Optimization
- **Real-time Data Access**: Fetch latest data directly from ModelContext rather than relying on cached arrays for critical display values
- **Thread Safety**: Ensure all ViewState database operations are wrapped with proper @MainActor annotations
- **Data Synchronization**: Implement comprehensive data refresh patterns after state-changing operations

### Gamification Best Practices
- **Progression Design**: 50-level system with meaningful title progression provides long-term engagement
- **Bonus Systems**: 2x experience for difficult problems creates balanced risk-reward mechanics
- **Visual Feedback**: Level-up animations significantly improve user satisfaction and retention