# Assets Directory

This directory contains all static assets used in the MAPIC Manager app.

## Structure

```
assets/
├── images/          # App images, logos, illustrations
├── icons/           # Custom icons and graphics
├── fonts/           # Custom fonts (Inter family)
├── animations/      # Lottie animations and other animated assets
└── sounds/          # Audio files for notifications and alerts
```

## Guidelines

### Images
- Use PNG for images with transparency
- Use JPEG for photos and complex images
- Optimize images for mobile (keep file sizes small)
- Provide multiple resolutions (1x, 2x, 3x) when needed

### Icons
- Use SVG format when possible
- Follow Material Design icon guidelines
- Maintain consistent style and sizing
- Use meaningful names (e.g., `user_profile.svg`)

### Fonts
- Inter font family is the primary typeface
- Include Regular, Medium, SemiBold, and Bold weights
- Ensure proper licensing for commercial use

### Animations
- Use Lottie format for complex animations
- Keep file sizes optimized
- Provide fallback static images

### Sounds
- Use MP3 or AAC format
- Keep audio files short (< 5 seconds for notifications)
- Provide different alert sounds for different types of notifications

## Usage in Code

```dart
// Images
Image.asset('assets/images/logo.png')

// Icons
SvgPicture.asset('assets/icons/dashboard.svg')

// Fonts (configured in pubspec.yaml)
TextStyle(fontFamily: 'Inter')

// Sounds
AudioPlayer().play(AssetSource('sounds/alert.mp3'))
```

## File Naming Convention

- Use lowercase with underscores: `user_profile.png`
- Be descriptive: `sos_alert_sound.mp3`
- Include size in filename if multiple sizes: `logo_small.png`, `logo_large.png`
- Use consistent prefixes for related assets: `icon_dashboard.svg`, `icon_users.svg`