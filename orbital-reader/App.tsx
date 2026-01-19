
import React, { useState, useRef, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { BookOpen, Library, Settings, Search, User as UserIcon, WifiOff, Globe, LogIn, Activity } from 'lucide-react';
import Orb from './components/Orb';
import OrbitMenu from './components/OrbitMenu';
import LibraryView from './views/LibraryView';
import ReaderView from './views/ReaderView';
import SettingsView from './views/SettingsView';
import ProfileView from './views/ProfileView';
import AuthView from './views/AuthView';
import ExploreView from './views/ExploreView';
import { DockPosition, MenuItem, Book, Language, User } from './types';
import { OrbitalDB } from './services/db';

const App: React.FC = () => {
  // Initialize DB
  useEffect(() => {
    OrbitalDB.init();
    const savedUser = OrbitalDB.getUser();
    if (savedUser) setUser(savedUser);
  }, []);

  // App State
  const [dockPosition, setDockPosition] = useState<DockPosition>('center');
  const [preferredDock, setPreferredDock] = useState<DockPosition>('left');
  const [activeItemId, setActiveItemId] = useState<string | null>(null);
  const [currentBook, setCurrentBook] = useState<Book | null>(null);
  
  // Auth & Offline State
  const [user, setUser] = useState<User | null>(null);
  const [isOfflineMode, setIsOfflineMode] = useState(false);

  // New Feature State
  const [autoHide, setAutoHide] = useState(false);
  const [edgeNav, setEdgeNav] = useState(false); 
  const [language, setLanguage] = useState<Language>('en');

  useEffect(() => {
    if (!autoHide && edgeNav) {
        setEdgeNav(false);
    }
  }, [autoHide, edgeNav]);

  const [isInteracting, setIsInteracting] = useState(false);
  const hoverTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const handleInteractionStart = () => {
    if (hoverTimeoutRef.current) {
        clearTimeout(hoverTimeoutRef.current);
        hoverTimeoutRef.current = null;
    }
    setIsInteracting(true);
  };

  const handleInteractionEnd = () => {
      if (hoverTimeoutRef.current) clearTimeout(hoverTimeoutRef.current);
      hoverTimeoutRef.current = setTimeout(() => {
          setIsInteracting(false);
      }, 300);
  };

  const t = {
      en: { 
          library: 'Library', reader: 'Continue', search: 'Explore', 
          profile: 'Profile', settings: 'Settings', offline: 'Offline Mode', login: 'Login',
          status: { online: 'System Online', offline: 'Offline Mode', guest: 'Guest Access' }
      },
      zh: { 
          library: '书库', reader: '继续阅读', search: '探索', 
          profile: '个人中心', settings: '设置', offline: '离线模式', login: '登录',
          status: { online: '系统在线', offline: '离线模式', guest: '游客访问' }
      }
  };

  const getMenuItems = (lang: Language): MenuItem[] => [
    { id: 'library', label: t[lang].library, icon: Library, targetDock: 'left', color: '#3b82f6' },
    { id: 'reader', label: t[lang].reader, icon: BookOpen, targetDock: 'top', color: '#10b981' },
    { id: 'search', label: t[lang].search, icon: Search, targetDock: 'left', color: '#f59e0b' },
    { id: 'profile', label: t[lang].profile, icon: UserIcon, targetDock: 'top', color: '#8b5cf6' },
    { id: 'settings', label: t[lang].settings, icon: Settings, targetDock: 'left', color: '#64748b' },
    { id: 'offline', label: t[lang].offline, icon: WifiOff, targetDock: 'center', color: '#94a3b8', special: true },
  ];

  const handleOrbClick = () => {
    setDockPosition('center');
    setActiveItemId(null);
  };

  const handleMenuItemClick = (item: MenuItem) => {
    if (item.id === 'offline') {
        setIsOfflineMode(true);
        setActiveItemId(null);
        setDockPosition('center');
        return;
    }

    if (!user && !isOfflineMode) {
        setDockPosition('center'); 
        setActiveItemId('auth');
        return;
    }

    if (activeItemId === item.id) return;
    
    if (!edgeNav) {
        setDockPosition(preferredDock);
    }
    setActiveItemId(item.id);
  };

  const handleLoginSuccess = (loggedInUser: User) => {
      setUser(loggedInUser);
      OrbitalDB.saveUser(loggedInUser);
      setIsOfflineMode(false); 
      setActiveItemId(null); 
      setDockPosition('center');
  };

  const handleLogout = () => {
      setUser(null);
      OrbitalDB.saveUser(null);
      setIsOfflineMode(false);
      setActiveItemId('auth'); 
      setDockPosition('center');
  };

  const handleBookSelect = (book: Book) => {
      // Add to DB if it's a new book from Search
      OrbitalDB.addBook(book);
      setCurrentBook(book);
      setDockPosition(preferredDock);
      setActiveItemId('reader');
  };

  const handleDockPreferenceChange = (newDock: DockPosition) => {
      setPreferredDock(newDock);
      if (dockPosition !== 'center') {
          setDockPosition(newDock);
          if (autoHide) {
              handleInteractionStart();
              if (hoverTimeoutRef.current) clearTimeout(hoverTimeoutRef.current);
              hoverTimeoutRef.current = setTimeout(() => {
                  setIsInteracting(false);
              }, 1000); 
          }
      }
  };

  const handleEdgeNavToggle = (isEnabled: boolean) => {
    setEdgeNav(isEnabled);
    if (!isEnabled) {
        setPreferredDock('left');
        if (dockPosition !== 'center') {
            setDockPosition('left');
        }
    }
  };

  const isOrbVisible = dockPosition === 'center' || !autoHide || isInteracting;

  const handleEdgeEnter = (edge: DockPosition) => {
      if (dockPosition === 'center') return; 
      if (edgeNav) {
          setDockPosition(edge);
      }
      if (autoHide) {
         if (edgeNav || edge === dockPosition) {
             handleInteractionStart();
         }
      }
  };

  const currentMenuItems = getMenuItems(language);
  const sharedGroupKey = dockPosition === 'center' ? 'center' : `dock-group-${dockPosition}`;

  return (
    <div className="relative w-screen h-screen bg-slate-950 overflow-hidden flex items-center justify-center">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_#1e293b_0%,_#020617_100%)] pointer-events-none" />
      <div className="absolute inset-0 opacity-20 pointer-events-none bg-[url('https://www.transparenttextures.com/patterns/stardust.png')]"></div>

      <div className="absolute top-6 right-6 z-40 flex items-center gap-4">
          <div className="hidden md:flex items-center space-x-2 px-3 py-1.5 rounded-full bg-slate-900/50 border border-slate-800 backdrop-blur-sm">
             {user ? (
                <>
                    <Activity size={12} className="text-emerald-500 animate-pulse" />
                    <span className="text-[10px] font-bold tracking-widest text-slate-400 uppercase">{t[language].status.online}</span>
                </>
             ) : isOfflineMode ? (
                <>
                    <WifiOff size={12} className="text-slate-500" />
                    <span className="text-[10px] font-bold tracking-widest text-slate-500 uppercase">{t[language].status.offline}</span>
                </>
             ) : (
                <>
                    <Globe size={12} className="text-blue-500/70" />
                    <span className="text-[10px] font-bold tracking-widest text-slate-500 uppercase">{t[language].status.guest}</span>
                </>
             )}
          </div>

          {user ? (
              <motion.button 
                  onClick={() => {
                      if (activeItemId !== 'profile') {
                          setActiveItemId('profile');
                          setDockPosition(preferredDock);
                      }
                  }}
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="flex items-center gap-3 bg-slate-800/80 hover:bg-slate-700 backdrop-blur-md rounded-full pl-1 pr-4 py-1 border border-slate-600/50 transition-all cursor-pointer group shadow-lg"
              >
                  <div className={`w-8 h-8 rounded-full ${user.avatar} flex items-center justify-center text-xs font-bold text-white shadow-inner`}>
                      {user.username.substring(0,2)}
                  </div>
                  <span className="text-xs font-bold text-slate-300 group-hover:text-white uppercase tracking-widest transition-colors">
                    {user.username}
                  </span>
              </motion.button>
          ) : (
            <motion.button 
                onClick={() => {
                    if (isOfflineMode) setIsOfflineMode(false);
                    setActiveItemId('auth');
                }}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className={`
                    flex items-center gap-2 px-5 py-2.5 rounded-full backdrop-blur-md border shadow-lg transition-all group
                    ${activeItemId === 'auth' ? 'bg-blue-600 border-blue-400 shadow-blue-500/30' : 'bg-slate-800/80 hover:bg-slate-700 border-slate-600'}
                `}
            >
                 <LogIn size={14} className={`${activeItemId === 'auth' ? 'text-white' : 'text-blue-400 group-hover:text-blue-300'}`} />
                <span className={`text-xs font-bold uppercase tracking-widest ${activeItemId === 'auth' ? 'text-white' : 'text-blue-400 group-hover:text-blue-300'}`}>
                    {t[language].login}
                </span>
            </motion.button>
          )}
      </div>

      {dockPosition !== 'center' && (
          <>
            <div className="absolute top-0 left-0 w-full h-8 z-40 bg-transparent" onMouseEnter={() => handleEdgeEnter('top')} onMouseLeave={handleInteractionEnd} />
            <div className="absolute bottom-0 left-0 w-full h-8 z-40 bg-transparent" onMouseEnter={() => handleEdgeEnter('bottom')} onMouseLeave={handleInteractionEnd} />
            <div className="absolute top-0 left-0 h-full w-8 z-40 bg-transparent" onMouseEnter={() => handleEdgeEnter('left')} onMouseLeave={handleInteractionEnd} />
            <div className="absolute top-0 right-0 h-full w-8 z-40 bg-transparent" onMouseEnter={() => handleEdgeEnter('right')} onMouseLeave={handleInteractionEnd} />
          </>
      )}

      <AnimatePresence mode='wait'>
        {activeItemId === 'auth' && (
            <motion.div 
                key="auth"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="absolute inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-md"
            >
                <AuthView 
                    language={language} 
                    onLoginSuccess={handleLoginSuccess} 
                    onClose={() => setActiveItemId(null)}
                />
            </motion.div>
        )}
        
        {activeItemId === 'library' && (
          <div key="library" className="absolute inset-0 z-0">
             <LibraryView onSelectBook={handleBookSelect} dockPosition={dockPosition} language={language} />
          </div>
        )}
        {activeItemId === 'reader' && (
            <div key="reader" className="absolute inset-0 z-0">
                <ReaderView dockPosition={dockPosition} language={language} book={currentBook} />
            </div>
        )}
        {activeItemId === 'settings' && (
            <div key="settings" className="absolute inset-0 z-0">
                <SettingsView 
                    preferredDock={preferredDock} 
                    onDockChange={handleDockPreferenceChange}
                    currentDockPosition={dockPosition}
                    autoHide={autoHide}
                    onAutoHideChange={setAutoHide}
                    edgeNav={edgeNav}
                    onEdgeNavChange={handleEdgeNavToggle}
                    language={language}
                    onLanguageChange={setLanguage}
                />
            </div>
        )}
        {activeItemId === 'profile' && (
            <div key="profile" className="absolute inset-0 z-0">
                <ProfileView 
                    user={user} 
                    language={language} 
                    onUpdateUser={(u) => { setUser(u); OrbitalDB.saveUser(u); }}
                    onLogout={handleLogout}
                />
            </div>
        )}
        {activeItemId === 'search' && (
             <div key="search" className="absolute inset-0 z-0">
                <ExploreView language={language} onSelectBook={handleBookSelect} />
             </div>
        )}
      </AnimatePresence>

      {activeItemId !== 'auth' && (
          <>
            <Orb 
                key={`orb-${sharedGroupKey}`} 
                position={dockPosition} 
                isHidden={!isOrbVisible}
                onClick={handleOrbClick} 
                onHoverStart={handleInteractionStart}
                onHoverEnd={handleInteractionEnd}
            />

            <OrbitMenu 
                key={`menu-${sharedGroupKey}`} 
                items={currentMenuItems} 
                currentDock={dockPosition}
                activeItemId={activeItemId}
                isHidden={!isOrbVisible}
                onItemClick={handleMenuItemClick}
                onHoverStart={handleInteractionStart}
                onHoverEnd={handleInteractionEnd}
            />
          </>
      )}
    </div>
  );
};

export default App;
