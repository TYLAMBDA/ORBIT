import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { DockPosition } from '../types';

interface OrbProps {
  position: DockPosition;
  isHidden: boolean;
  onClick: () => void;
  onHoverStart: () => void;
  onHoverEnd: () => void;
}

const Orb: React.FC<OrbProps> = ({ position, isHidden, onClick, onHoverStart, onHoverEnd }) => {
  
  // Responsive State
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  // GEOMETRY CONSTANTS
  // Desktop: Orb 18rem (288px), Center 28rem
  // Mobile:  Orb 12rem (192px), Center 18rem
  
  const size = {
    center: isMobile ? '18rem' : '28rem',
    docked: isMobile ? '12rem' : '18rem',
  };

  // Offsets for Docked Positions
  // Desktop: -16rem (Visible), -20rem (Hidden)
  // Mobile:  -10.5rem (Visible), -13rem (Hidden) -> 1.5rem (24px) visible sliver
  const offset = {
      visible: isMobile ? '10.5rem' : '16rem',
      hidden: isMobile ? '13rem' : '20rem',
  };

  const variants = {
    // CENTER MODE
    center: {
      width: size.center, 
      height: size.center,
      top: '50%',
      left: '50%',
      x: '-50%',
      y: '-50%',
      opacity: 1,
      scale: 1,
      background: 'radial-gradient(circle at 30% 30%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: '0 0 80px rgba(37, 99, 235, 0.5), inset 0 0 40px rgba(255,255,255,0.2)',
    },

    // LEFT
    left_visible: {
      width: size.docked, height: size.docked, top: '50%', y: '-50%', x: '0%', scale: 1,
      left: `-${offset.visible}`,
      opacity: 1,
      background: 'radial-gradient(circle at 80% 50%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: '0 0 30px rgba(37, 99, 235, 0.3)',
    },
    left_hidden: {
      width: size.docked, height: size.docked, top: '50%', y: '-50%', x: '0%', scale: 1,
      left: `-${offset.hidden}`,
      opacity: 0,
      background: 'radial-gradient(circle at 80% 50%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: 'none',
    },

    // RIGHT
    right_visible: {
      width: size.docked, height: size.docked, top: '50%', y: '-50%', x: '-100%', scale: 1,
      left: `calc(100% + ${offset.visible})`, 
      opacity: 1,
      background: 'radial-gradient(circle at 20% 50%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: '0 0 30px rgba(37, 99, 235, 0.3)',
    },
    right_hidden: {
      width: size.docked, height: size.docked, top: '50%', y: '-50%', x: '-100%', scale: 1,
      left: `calc(100% + ${offset.hidden})`,
      opacity: 0,
      background: 'radial-gradient(circle at 20% 50%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: 'none',
    },

    // TOP
    top_visible: {
      width: size.docked, height: size.docked, left: '50%', x: '-50%', y: '0%', scale: 1,
      top: `-${offset.visible}`,
      opacity: 1,
      background: 'radial-gradient(circle at 50% 80%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: '0 0 30px rgba(37, 99, 235, 0.3)',
    },
    top_hidden: {
      width: size.docked, height: size.docked, left: '50%', x: '-50%', y: '0%', scale: 1,
      top: `-${offset.hidden}`,
      opacity: 0,
      background: 'radial-gradient(circle at 50% 80%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: 'none',
    },

    // BOTTOM
    bottom_visible: {
      width: size.docked, height: size.docked, left: '50%', x: '-50%', y: '-100%', scale: 1,
      top: `calc(100% + ${offset.visible})`,
      opacity: 1,
      background: 'radial-gradient(circle at 50% 20%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: '0 0 30px rgba(37, 99, 235, 0.3)',
    },
    bottom_hidden: {
      width: size.docked, height: size.docked, left: '50%', x: '-50%', y: '-100%', scale: 1,
      top: `calc(100% + ${offset.hidden})`,
      opacity: 0,
      background: 'radial-gradient(circle at 50% 20%, #60a5fa, #2563eb, #1e3a8a)',
      boxShadow: 'none',
    },
  };

  const currentVariant = position === 'center' ? 'center' : `${position}_${isHidden ? 'hidden' : 'visible'}`;
  const initialVariant = position === 'center' ? 'center' : `${position}_hidden`;

  return (
    <motion.div
      initial={initialVariant}
      animate={currentVariant}
      variants={variants}
      transition={{ type: 'spring', stiffness: 100, damping: 20, mass: 1 }}
      className="absolute z-50 cursor-pointer rounded-full"
      onClick={onClick}
      onHoverStart={onHoverStart}
      onHoverEnd={onHoverEnd}
    >
      {!isHidden && (
        <div className="absolute inset-0 rounded-full opacity-30 mix-blend-overlay bg-[url('https://www.transparenttextures.com/patterns/stardust.png')]"></div>
      )}
      
      {position === 'center' && (
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="absolute inset-0 flex items-center justify-center flex-col text-white pointer-events-none"
        >
          <span className={`font-bold tracking-tighter drop-shadow-lg ${isMobile ? 'text-4xl' : 'text-6xl'}`}>ORBIT</span>
          <span className="text-sm uppercase tracking-[0.3em] opacity-80 mt-2 text-blue-200">Reader OS</span>
        </motion.div>
      )}
    </motion.div>
  );
};

export default Orb;
