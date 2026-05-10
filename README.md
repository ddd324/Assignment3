# SnapRead - Ebook Reader App

SnapRead is a modern iOS reading application built with SwiftUI, designed to provide a smooth and personalized digital reading experience.

The app focuses on reading, progress tracking, and social interaction, providing a complete user-centered reading workflow.

---

## Features

### Book Management
- Built-in EPUB book library
- Automatically parses:
  - Title
  - Author
  - Chapters
  - Cover image
  - Description
- Books are categorized automatically
- Data is stored locally and persists after app restart

---

### Home Page
- Recommended for You – displays all available books
- Latest – recently added books (latest first)
- Recently Viewed – dynamically updated based on user activity
- Horizontal scrolling book cards for smooth browsing

---

### My Books
- Add/remove books using a favorite system
- Displays reading progress for each book
- Only user-selected books appear here
- Progress is saved locally and persists

---

### Reading Experience
- Chapter-based reading
- Swipe navigation between chapters
- Table of Contents (TOC) support
- Resume reading from last position
- Customizable:
  - Font size
  - Theme (light/dark)
  - Brightness
- Reading progress automatically saved

---

### Comments System
- Users can post comments on books
- Comments are stored locally
- Displayed in:
  - Book detail page
  - Readers page

---

### Readers Page
- Recommended – all comments
- Following – comments from followed users
- Mine – user's own comments
- Supports follow/unfollow interaction
- Displays:
  - Username
  - Avatar
  - Comment content
  - Related book

---

### User System
- Local authentication system
- Register with:
  - Username
  - Avatar
- Login state persists after restart
- Each user has independent data:
  - Reading progress
  - Comments
  - Following relationships

---

### Profile Page
- Displays:
  - Books count
  - Following count
  - Followers count
- Summary cards:
  - Reading Books
  - My Comments
- Navigation to:
  - My Books
  - Personal comments
- Avatar displayed across the app

---

## Data Persistence

All data is stored locally using:

- UserDefaults
- JSON encoding/decoding

Stored data includes:
- Books
- User accounts
- Reading progress
- Comments
- Following relationships
- Recently viewed books
