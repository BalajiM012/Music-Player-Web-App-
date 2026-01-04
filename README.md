🎵 Wave Music Player

A modern, beautiful music player with real-time audio visualization built with React and Web Audio API.

## Features

- 🎨 Stunning UI with glassmorphism effects
- 📊 Real-time audio visualization
- 🎵 Full playback controls (play, pause, skip, shuffle, repeat)
- 📱 Responsive design
- 🎚️ Volume control with mute
- 📋 Playlist management
- ⚡ Built with Vite for fast development

## Tech Stack

- React 18
- Vite
- Tailwind CSS
- Web Audio API
- Lucide React Icons

## Getting Started

### Installation

1. Clone the repository:
\`\`\`bash
git clone https://github.com/yourusername/wave-music-player.git
cd wave-music-player
\`\`\`

2. Install dependencies:
\`\`\`bash
npm install
\`\`\`

3. Start development server:
\`\`\`bash
npm run dev
\`\`\`

4. Open http://localhost:5173 in your browser

### Building for Production

\`\`\`bash
npm run build
\`\`\`

### Preview Production Build

\`\`\`bash
npm run preview
\`\`\`

## Deployment

### Deploy to Vercel

1. Install Vercel CLI:
\`\`\`bash
npm i -g vercel
\`\`\`

2. Deploy:
\`\`\`bash
vercel
\`\`\`

### Deploy to Netlify

1. Install Netlify CLI:
\`\`\`bash
npm i -g netlify-cli
\`\`\`

2. Deploy:
\`\`\`bash
netlify deploy --prod
\`\`\`

Or connect your GitHub repository to Vercel/Netlify for automatic deployments.

## Usage

1. Click "Upload" button to add audio files
2. Select tracks from your device
3. Use playback controls to manage your music
4. Toggle playlist view to see all tracks
5. Enjoy the audio visualization!

## Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge

Requires support for Web Audio API and Canvas API.

## License

MIT

## Author

Your Name
\`\`\`

---

## 🚀 Quick Setup Commands

```bash
# Create project
npm create vite@latest wave-music-player -- --template react
cd wave-music-player

# Install dependencies
npm install lucide-react

# Install Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Start development
npm run dev

# Build for production
npm run build

# Deploy to Vercel (if installed)
vercel --prod

# Deploy to Netlify (if installed)
netlify deploy --prod
```

---

## 📝 Important Notes

1. **Place your video file** `56189-480695649_small.mp4` in the `public/` folder
2. **StylishMusicPlayer.jsx** goes in `src/components/` folder
3. Make sure to **create all config files** (tailwind.config.js, postcss.config.js)
4. The player uses **Web Audio API** - ensure HTTPS in production for best compatibility
5. Audio files are **client-side only** - no server storage needed

---

## 🎨 Customization

You can customize colors in the component by modifying the gradient values:
- Main gradient: `from-cyan-500 via-purple-500 to-pink-500`
- Background: `from-slate-950 via-indigo-950 to-purple-950`
- Buttons: `bg-purple-600`, `bg-cyan-600`

---

## 🐛 Troubleshooting

**Audio not playing?**
- Check browser console for errors
- Ensure audio files are valid
- Try different audio formats (MP3, WAV, OGG)

**Visualizer not working?**
- Web Audio API requires user interaction to start
- Click play button to initialize audio context
- Check browser compatibility

**Build fails?**
- Delete `node_modules` and `package-lock.json`
- Run `npm install` again
- Check Node.js version (recommended: 18+)
```

---

## 🎯 Step-by-Step Deployment

### Option 1: GitHub + Vercel (Recommended)

1. **Push to GitHub:**
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/wave-music-player.git
git push -u origin main
```

2. **Deploy on Vercel:**
   - Go to https://vercel.com
   - Click "New Project"
   - Import your GitHub repository
   - Vercel auto-detects Vite settings
   - Click "Deploy"

### Option 2: GitHub + Netlify

1. **Push to GitHub** (same as above)

2. **Deploy on Netlify:**
   - Go to https://netlify.com
   - Click "Add new site" → "Import an existing project"
   - Connect to GitHub
   - Select your repository
   - Build settings are auto-detected from `netlify.toml`
   - Click "Deploy"

---

## ✨ Additional Features You Can Add

1. **Lyrics Display**
2. **Equalizer Controls**
3. **Theme Switcher**
4. **Save Playlists to localStorage**
5. **Keyboard Shortcuts**
6. **Full-Screen Mode**
7. **Social Sharing**
8. **Audio Effects (Bas
