# LCVA Portal iOS Application

## Overview
The LCVA Portal is a native iOS application developed for the Longwood Center for Visual Arts (LCVA). This application serves as a digital gateway to LCVA's art collections, enabling users to explore, interact with, and learn about various artworks in the museum.

## Features

### Collections Management
- Browse the complete LCVA museum collection
- Filter artworks by various collections (African Art, American Art, etc.)
- Create personal collections of favorite artworks
- Add/remove artworks to personal collections
- Mark artworks as favorites within collections

### Art Piece Interaction
- View detailed information about each artwork
- High-quality artwork images
- Artwork metadata (title, artist, era, materials, etc.)
- Location information for displayed pieces
- Accessibility features (translations, audio tours, braille labels)

### Social Features
- Real-time chat discussions about specific artworks
- User authentication via Firebase
- Personal user profiles
- Share thoughts and insights about artworks

### Technical Implementation
- **Backend Services**:
  - Supabase for art collection data
  - Firebase for user authentication and real-time chat
  - Cloud storage for high-resolution images

- **Data Models**:
  - UUID-based artifact identification
  - Structured art piece information
  - User collection management
  - Chat message system

- **UI/UX**:
  - SwiftUI-based interface
  - Responsive grid and list views
  - Custom navigation system
  - Dynamic filtering and search

## Architecture
- Modern Swift concurrency with async/await
- MVVM architecture
- Component-based UI design
- Real-time data synchronization

## Dependencies
- Firebase
- FirebaseFirestore
- SwiftUI
- Supabase Client

## Copyright
© 2024 Sun English and Longwood Center for Visual Arts. All rights reserved.
This application and its source code are the property of Sun English and LCVA.
Unauthorized copying, modification, or distribution is prohibited.
