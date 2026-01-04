
import React, { useState, useRef, useEffect } from 'react';
import { Play, Pause, SkipBack, SkipForward, Volume2, VolumeX, Upload, List, Shuffle, Repeat, Music, X, Waves, Palette } from 'lucide-react';
import { argbFromHex, themeFromSourceColor, hexFromArgb } from '@material/material-color-utilities';

const StylishMusicPlayer = () => {
  const [playlist, setPlaylist] = useState([]);
  const [currentTrackIndex, setCurrentTrackIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(70);
  const [isMuted, setIsMuted] = useState(false);
  const [isShuffled, setIsShuffled] = useState(false);
  const [repeatMode, setRepeatMode] = useState('none');
  const [showPlaylist, setShowPlaylist] = useState(false);
  const [analyserReady, setAnalyserReady] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [theme, setTheme] = useState(null);
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [sourceColor, setSourceColor] = useState('#6750A4');
  
  const audioRef = useRef(null);
  const audioContextRef = useRef(null);
  const analyserRef = useRef(null);
  const sourceRef = useRef(null);
  const canvasRef = useRef(null);
  const animationRef = useRef(null);

  // Generate Material You theme
  useEffect(() => {
    const generateTheme = () => {
      const materialTheme = themeFromSourceColor(argbFromHex(sourceColor));
      setTheme(materialTheme);
    };
    generateTheme();
  }, [sourceColor]);

  // Get theme colors
  const getColors = () => {
    if (!theme) return null;
    
    const scheme = isDarkMode ? theme.schemes.dark : theme.schemes.light;
    
    return {
      primary: hexFromArgb(scheme.primary),
      onPrimary: hexFromArgb(scheme.onPrimary),
      primaryContainer: hexFromArgb(scheme.primaryContainer),
      onPrimaryContainer: hexFromArgb(scheme.onPrimaryContainer),
      secondary: hexFromArgb(scheme.secondary),
      onSecondary: hexFromArgb(scheme.onSecondary),
      secondaryContainer: hexFromArgb(scheme.secondaryContainer),
      tertiary: hexFromArgb(scheme.tertiary),
      surface: hexFromArgb(scheme.surface),
      surfaceContainer: hexFromArgb(scheme.surfaceContainer),
      surfaceContainerHigh: hexFromArgb(scheme.surfaceContainerHigh),
      surfaceContainerHighest: hexFromArgb(scheme.surfaceContainerHighest),
      onSurface: hexFromArgb(scheme.onSurface),
      onSurfaceVariant: hexFromArgb(scheme.onSurfaceVariant),
      outline: hexFromArgb(scheme.outline),
      background: hexFromArgb(scheme.background),
      error: hexFromArgb(scheme.error),
    };
  };

  const colors = getColors();

  const initAudioContext = () => {
    if (audioContextRef.current) return;
    
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioContext.createAnalyser();
    analyser.fftSize = 256;
    analyser.smoothingTimeConstant = 0.85;
    
    const source = audioContext.createMediaElementSource(audioRef.current);
    const gainNode = audioContext.createGain();
    
    source.connect(gainNode);
    gainNode.connect(analyser);
    analyser.connect(audioContext.destination);
    
    audioContextRef.current = audioContext;
    analyserRef.current = analyser;
    sourceRef.current = source;
    setAnalyserReady(true);
  };

  const handleFileUpload = (e) => {
    const files = Array.from(e.target.files);
    const audioFiles = files.filter(file => file.type.startsWith('audio/'));
    
    const newTracks = audioFiles.map((file, index) => ({
      id: Date.now() + index,
      name: file.name.replace(/\.[^/.]+$/, ""),
      file: file,
      url: URL.createObjectURL(file),
      duration: 0
    }));
    
    setPlaylist(prev => [...prev, ...newTracks]);
    if (playlist.length === 0 && newTracks.length > 0) {
      loadTrack(0, newTracks);
    }
  };

  const loadTrack = (index, trackList = playlist) => {
    if (index < 0 || index >= trackList.length) return;
    
    const track = trackList[index];
    if (audioRef.current) {
      audioRef.current.src = track.url;
      setCurrentTrackIndex(index);
      setCurrentTime(0);
    }
  };

  const togglePlay = async () => {
    if (!audioRef.current || playlist.length === 0) return;
    
    if (!audioContextRef.current) {
      initAudioContext();
    }
    
    if (audioContextRef.current.state === 'suspended') {
      await audioContextRef.current.resume();
    }
    
    if (isPlaying) {
      audioRef.current.pause();
    } else {
      audioRef.current.play();
    }
    setIsPlaying(!isPlaying);
  };

  const nextTrack = () => {
    let nextIndex;
    if (isShuffled) {
      nextIndex = Math.floor(Math.random() * playlist.length);
    } else {
      nextIndex = (currentTrackIndex + 1) % playlist.length;
    }
    loadTrack(nextIndex);
    if (isPlaying) {
      setTimeout(() => audioRef.current?.play(), 100);
    }
  };

  const prevTrack = () => {
    if (currentTime > 3) {
      audioRef.current.currentTime = 0;
    } else {
      const prevIndex = (currentTrackIndex - 1 + playlist.length) % playlist.length;
      loadTrack(prevIndex);
      if (isPlaying) {
        setTimeout(() => audioRef.current?.play(), 100);
      }
    }
  };

  const handleVolumeChange = (e) => {
    const newVolume = parseInt(e.target.value);
    setVolume(newVolume);
    if (audioRef.current) {
      audioRef.current.volume = newVolume / 100;
    }
    if (newVolume > 0) setIsMuted(false);
  };

  const toggleMute = () => {
    setIsMuted(!isMuted);
    if (audioRef.current) {
      audioRef.current.muted = !isMuted;
    }
  };

  const handleSeek = (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percentage = x / rect.width;
    const newTime = percentage * duration;
    if (audioRef.current) {
      audioRef.current.currentTime = newTime;
    }
  };

  const formatTime = (time) => {
    if (isNaN(time)) return '0:00';
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const drawVisualizer = () => {
    if (!analyserRef.current || !canvasRef.current || !colors) return;
    
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const analyser = analyserRef.current;
    
    canvas.width = canvas.offsetWidth * window.devicePixelRatio;
    canvas.height = canvas.offsetHeight * window.devicePixelRatio;
    ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    
    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    
    const draw = () => {
      animationRef.current = requestAnimationFrame(draw);
      analyser.getByteFrequencyData(dataArray);
      
      ctx.fillStyle = colors.surface;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      
      const barCount = 64;
      const barWidth = (canvas.width / window.devicePixelRatio / barCount) - 2;
      const centerY = canvas.height / window.devicePixelRatio / 2;
      
      for (let i = 0; i < barCount; i++) {
        const dataIndex = Math.floor(i * bufferLength / barCount);
        const barHeight = (dataArray[dataIndex] / 255) * centerY * 0.9;
        
        const gradient = ctx.createLinearGradient(0, centerY - barHeight, 0, centerY + barHeight);
        gradient.addColorStop(0, colors.primary);
        gradient.addColorStop(0.5, colors.tertiary);
        gradient.addColorStop(1, colors.secondary);
        
        ctx.fillStyle = gradient;
        ctx.globalAlpha = 0.8;
        
        const x = i * (barWidth + 2);
        ctx.fillRect(x, centerY - barHeight, barWidth, barHeight);
        ctx.fillRect(x, centerY, barWidth, barHeight);
      }
      ctx.globalAlpha = 1;
    };
    
    draw();
  };

  const removeTrack = (e, trackId) => {
    e.stopPropagation();
    const newPlaylist = playlist.filter(t => t.id !== trackId);
    setPlaylist(newPlaylist);
    
    if (playlist[currentTrackIndex]?.id === trackId) {
      if (newPlaylist.length > 0) {
        const newIndex = Math.min(currentTrackIndex, newPlaylist.length - 1);
        loadTrack(newIndex, newPlaylist);
      } else {
        setIsPlaying(false);
        setCurrentTrackIndex(0);
      }
    }
  };

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;
    
    const handleTimeUpdate = () => setCurrentTime(audio.currentTime);
    const handleLoadedMetadata = () => setDuration(audio.duration);
    const handleEnded = () => {
      if (repeatMode === 'one') {
        audio.currentTime = 0;
        audio.play();
      } else if (repeatMode === 'all' || isShuffled) {
        nextTrack();
      } else if (currentTrackIndex < playlist.length - 1) {
        nextTrack();
      } else {
        setIsPlaying(false);
      }
    };
    
    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('ended', handleEnded);
    audio.addEventListener('play', () => setIsPlaying(true));
    audio.addEventListener('pause', () => setIsPlaying(false));
    
    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('ended', handleEnded);
    };
  }, [repeatMode, currentTrackIndex, playlist.length, isShuffled]);

  useEffect(() => {
    if (analyserReady && isPlaying) {
      drawVisualizer();
    }
    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [analyserReady, isPlaying, colors]);

  const currentTrack = playlist[currentTrackIndex];

  if (!colors) return <div style={{ background: '#121212', color: 'white', minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>Loading...</div>;

  return (
    <div style={{ 
      minHeight: '100vh', 
      background: colors.background,
      color: colors.onSurface,
      transition: 'all 0.3s ease'
    }}>
      {/* Theme Controls */}
      <div style={{
        position: 'fixed',
        top: '1rem',
        right: '1rem',
        zIndex: 50,
        display: 'flex',
        gap: '0.5rem',
        background: colors.surfaceContainerHigh,
        padding: '0.5rem',
        borderRadius: '1rem',
        border: `1px solid ${colors.outline}`,
        backdropFilter: 'blur(10px)'
      }}>
        <button
          onClick={() => setIsDarkMode(!isDarkMode)}
          style={{
            padding: '0.5rem 1rem',
            borderRadius: '0.5rem',
            background: colors.secondaryContainer,
            color: colors.onSurface,
            border: 'none',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          {isDarkMode ? '☀️ Light' : '🌙 Dark'}
        </button>
        <input
          type="color"
          value={sourceColor}
          onChange={(e) => setSourceColor(e.target.value)}
          style={{
            width: '3rem',
            height: '2.5rem',
            borderRadius: '0.5rem',
            border: 'none',
            cursor: 'pointer'
          }}
          title="Change theme color"
        />
      </div>

      <div style={{ 
        position: 'relative', 
        zIndex: 10, 
        minHeight: '100vh', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center', 
        padding: '1rem' 
      }}>
        <div style={{ width: '100%', maxWidth: '80rem' }}>
          {/* Header */}
          <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <Waves style={{ width: '2.5rem', height: '2.5rem', color: colors.primary }} />
              <h1 style={{ 
                fontSize: '3.75rem', 
                fontWeight: '900',
                background: `linear-gradient(to right, ${colors.primary}, ${colors.tertiary}, ${colors.secondary})`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text'
              }}>
                WAVE
              </h1>
            </div>
            <p style={{ color: colors.onSurfaceVariant, fontSize: '1.125rem' }}>Material You Music Experience</p>
          </div>

          {/* Main Player Card */}
          <div style={{ 
            background: colors.surfaceContainer,
            borderRadius: '1.5rem',
            border: `1px solid ${colors.outline}`,
            overflow: 'hidden',
            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
          }}>
            {/* Visualizer */}
            <div style={{ position: 'relative', height: '16rem', background: colors.surface }}>
              <canvas
                ref={canvasRef}
                style={{ width: '100%', height: '100%' }}
              />
              {!isPlaying && (
                <div style={{ 
                  position: 'absolute', 
                  inset: 0, 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'center' 
                }}>
                  <Music style={{ width: '4rem', height: '4rem', color: colors.outline, opacity: 0.3 }} />
                </div>
              )}
            </div>

            {/* Track Info */}
            <div style={{ padding: '2rem' }}>
              <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                <h2 style={{ 
                  fontSize: '1.875rem', 
                  fontWeight: '700', 
                  marginBottom: '0.5rem',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  color: colors.onSurface
                }}>
                  {currentTrack ? currentTrack.name : 'No Track Playing'}
                </h2>
                <p style={{ color: colors.onSurfaceVariant }}>
                  {playlist.length > 0 ? `${currentTrackIndex + 1} / ${playlist.length}` : 'Upload tracks to begin'}
                </p>
              </div>

              {/* Progress Bar */}
              <div style={{ marginBottom: '2rem' }}>
                <div
                  onClick={handleSeek}
                  onMouseEnter={() => setIsDragging(true)}
                  onMouseLeave={() => setIsDragging(false)}
                  style={{
                    height: '0.5rem',
                    background: colors.surfaceContainerHighest,
                    borderRadius: '9999px',
                    cursor: 'pointer',
                    position: 'relative'
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      background: colors.primary,
                      borderRadius: '9999px',
                      width: `${(currentTime / duration) * 100}%`,
                      transition: 'all 0.1s',
                      position: 'relative'
                    }}
                  >
                    <div style={{
                      position: 'absolute',
                      right: 0,
                      top: '50%',
                      transform: `translateY(-50%) scale(${isDragging ? 1.25 : 0})`,
                      width: '1rem',
                      height: '1rem',
                      background: colors.onPrimary,
                      borderRadius: '50%',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                      transition: 'transform 0.2s'
                    }}></div>
                  </div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.875rem', color: colors.onSurfaceVariant, marginTop: '0.5rem' }}>
                  <span>{formatTime(currentTime)}</span>
                  <span>{formatTime(duration)}</span>
                </div>
              </div>

              {/* Main Controls */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '1rem', marginBottom: '2rem' }}>
                <button
                  onClick={() => setIsShuffled(!isShuffled)}
                  style={{
                    padding: '0.75rem',
                    borderRadius: '9999px',
                    background: isShuffled ? colors.primaryContainer : 'transparent',
                    color: isShuffled ? colors.onPrimaryContainer : colors.onSurface,
                    border: 'none',
                    cursor: 'pointer',
                    transition: 'all 0.2s'
                  }}
                >
                  <Shuffle size={20} />
                </button>

                <button
                  onClick={prevTrack}
                  disabled={playlist.length === 0}
                  style={{
                    padding: '1rem',
                    borderRadius: '9999px',
                    background: 'transparent',
                    color: colors.onSurface,
                    border: 'none',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                    opacity: playlist.length === 0 ? 0.5 : 1
                  }}
                >
                  <SkipBack size={24} />
                </button>

                <button
                  onClick={togglePlay}
                  disabled={playlist.length === 0}
                  style={{
                    padding: '1.5rem',
                    borderRadius: '9999px',
                    background: colors.primary,
                    color: colors.onPrimary,
                    border: 'none',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                    boxShadow: `0 10px 15px -3px ${colors.primary}40`,
                    opacity: playlist.length === 0 ? 0.5 : 1
                  }}
                >
                  {isPlaying ? <Pause size={32} /> : <Play size={32} style={{ marginLeft: '0.25rem' }} />}
                </button>

                <button
                  onClick={nextTrack}
                  disabled={playlist.length === 0}
                  style={{
                    padding: '1rem',
                    borderRadius: '9999px',
                    background: 'transparent',
                    color: colors.onSurface,
                    border: 'none',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                    opacity: playlist.length === 0 ? 0.5 : 1
                  }}
                >
                  <SkipForward size={24} />
                </button>

                <button
                  onClick={() => {
                    const modes = ['none', 'all', 'one'];
                    const currentIndex = modes.indexOf(repeatMode);
                    setRepeatMode(modes[(currentIndex + 1) % modes.length]);
                  }}
                  style={{
                    padding: '0.75rem',
                    borderRadius: '9999px',
                    background: repeatMode !== 'none' ? colors.primaryContainer : 'transparent',
                    color: repeatMode !== 'none' ? colors.onPrimaryContainer : colors.onSurface,
                    border: 'none',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                    position: 'relative'
                  }}
                >
                  <Repeat size={20} />
                  {repeatMode === 'one' && (
                    <span style={{
                      position: 'absolute',
                      top: '-0.25rem',
                      right: '-0.25rem',
                      fontSize: '0.75rem',
                      background: colors.tertiary,
                      color: colors.onPrimary,
                      width: '1.25rem',
                      height: '1.25rem',
                      borderRadius: '9999px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>1</span>
                  )}
                </button>
              </div>

              {/* Bottom Controls */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '1rem' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                  <button 
                    onClick={toggleMute}
                    style={{
                      padding: '0.5rem',
                      borderRadius: '0.5rem',
                      background: 'transparent',
                      color: colors.onSurface,
                      border: 'none',
                      cursor: 'pointer',
                      transition: 'all 0.2s'
                    }}
                  >
                    {isMuted || volume === 0 ? <VolumeX size={20} /> : <Volume2 size={20} />}
                  </button>
                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={volume}
                    onChange={handleVolumeChange}
                    style={{
                      width: '8rem',
                      height: '0.25rem',
                      borderRadius: '0.5rem',
                      appearance: 'none',
                      cursor: 'pointer',
                      background: `linear-gradient(to right, ${colors.primary} 0%, ${colors.primary} ${volume}%, ${colors.surfaceContainerHighest} ${volume}%, ${colors.surfaceContainerHighest} 100%)`
                    }}
                  />
                  <span style={{ fontSize: '0.875rem', width: '3rem', color: colors.onSurfaceVariant }}>{volume}%</span>
                </div>

                <div style={{ display: 'flex', gap: '0.5rem' }}>
                  <label style={{
                    cursor: 'pointer',
                    background: colors.primary,
                    color: colors.onPrimary,
                    padding: '0.75rem 1.5rem',
                    borderRadius: '9999px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    transition: 'all 0.2s',
                    fontWeight: '500'
                  }}>
                    <Upload size={20} />
                    <span>Upload</span>
                    <input
                      type="file"
                      multiple
                      accept="audio/*"
                      onChange={handleFileUpload}
                      style={{ display: 'none' }}
                    />
                  </label>

                  <button
                    onClick={() => setShowPlaylist(!showPlaylist)}
                    style={{
                      padding: '0.75rem 1.5rem',
                      borderRadius: '9999px',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.5rem',
                      transition: 'all 0.2s',
                      background: showPlaylist ? colors.secondaryContainer : colors.surfaceContainerHighest,
                      color: showPlaylist ? colors.onSecondaryContainer : colors.onSurface,
                      border: 'none',
                      cursor: 'pointer',
                      fontWeight: '500'
                    }}
                  >
                    <List size={20} />
                    <span>{playlist.length}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Playlist */}
          {showPlaylist && (
            <div style={{
              marginTop: '1.5rem',
              background: colors.surfaceContainer,
              borderRadius: '1.5rem',
              border: `1px solid ${colors.outline}`,
              padding: '1.5rem',
              maxHeight: '24rem',
              overflowY: 'auto'
            }}>
              <h3 style={{ 
                fontSize: '1.5rem', 
                fontWeight: '700', 
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                color: colors.onSurface
              }}>
                <List style={{ color: colors.primary }} />
                Playlist
              </h3>
              {playlist.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '3rem 0' }}>
                  <Music style={{ width: '4rem', height: '4rem', color: colors.outline, opacity: 0.3, margin: '0 auto 1rem' }} />
                  <p style={{ color: colors.onSurfaceVariant }}>No tracks yet. Upload some music!</p>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                  {playlist.map((track, index) => (
                    <div
                      key={track.id}
                      onClick={() => {
                        loadTrack(index);
                        if (isPlaying) setTimeout(() => audioRef.current?.play(), 100);
                      }}
                      style={{
                        padding: '1rem',
                        borderRadius: '0.75rem',
                        cursor: 'pointer',
                        transition: 'all 0.2s',
                        background: index === currentTrackIndex ? colors.primaryContainer : colors.surfaceContainerHigh,
                        color: index === currentTrackIndex ? colors.onPrimaryContainer : colors.onSurface
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', flex: 1, minWidth: 0 }}>
                          <div style={{
                            width: '2.5rem',
                            height: '2.5rem',
                            borderRadius: '0.5rem',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            background: index === currentTrackIndex ? colors.primary : colors.surfaceContainerHighest,
                            color: index === currentTrackIndex ? colors.onPrimary : colors.onSurface
                          }}>
                            {index === currentTrackIndex && isPlaying ? (
                              <div style={{ display: 'flex', gap: '0.25rem' }}>
                                <div style={{ width: '0.25rem', height: '1rem', background: 'currentColor', borderRadius: '9999px', animation: 'pulse 1s infinite' }}></div>
                                <div style={{ width: '0.25rem', height: '1rem', background: 'currentColor', borderRadius: '9999px', animation: 'pulse 1s infinite 0.2s' }}></div>
                                <div style={{ width: '0.25rem', height: '1rem', background: 'currentColor', borderRadius: '9999px', animation: 'pulse 1s infinite 0.4s' }}></div>
                              </div>
                            ) : (
                              <Music size={16} />
                            )}
                          </div>
                          <span style={{ fontWeight: '500', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{track.name}</span>
                        </div>
                        <button
                          onClick={(e) => removeTrack(e, track.id)}
                          style={{
                            padding: '0.5rem',
                            borderRadius: '0.5rem',
                            background: 'transparent',
                            color: colors.error,
                            border: 'none',
                            cursor: 'pointer',
                            transition: 'all 0.2s',
                            opacity: 0
                          }}
                          onMouseEnter={(e) => e
