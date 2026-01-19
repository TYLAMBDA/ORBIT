import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { MenuItem, DockPosition } from '../types';

interface OrbitMenuProps {
  items: MenuItem[];
  currentDock: DockPosition;
  activeItemId: string | null;
  isHidden: boolean;
  onItemClick: (item: MenuItem) => void;
  onHoverStart: () => void;
  onHoverEnd: () => void;
}

const OrbitMenu: React.FC<OrbitMenuProps> = ({ items, currentDock, activeItemId, isHidden, onItemClick, onHoverStart, onHoverEnd }) => {
  
  // Responsive State
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  // GEOMETRY CALCULATION
  const radius = currentDock === 'center' 
    ? (isMobile ? 150 : 280) 
    : (isMobile ? 110 : 200);

  const centerOffset = isMobile ? -72 : -112; 
  const hideShift = isMobile ? 40 : 64; 

  const getPosition = (index: number, total: number, dock: DockPosition) => {
    let angle = 0;
    let baseLeft = '';
    let baseTop = '';
    
    // Position Calculations
    if (dock === 'center') {
      const angleStep = 360 / total;
      angle = (index * angleStep - 90) * (Math.PI / 180);
      baseLeft = `calc(50% + ${Math.cos(angle) * radius}px)`;
      baseTop = `calc(50% + ${Math.sin(angle) * radius}px)`;
    } else if (dock === 'left') {
        const start = -40; const end = 40; const step = (end - start) / (total - 1);
        angle = (start + index * step) * (Math.PI / 180);
        baseLeft = `calc(0% + ${centerOffset + Math.cos(angle) * radius}px)`;
        baseTop = `calc(50% + ${Math.sin(angle) * radius}px)`;
    } else if (dock === 'right') {
        const start = 140; const end = 220; const step = (end - start) / (total - 1);
        angle = (start + index * step) * (Math.PI / 180);
        baseLeft = `calc(100% + ${Math.abs(centerOffset) + Math.cos(angle) * radius}px)`;
        baseTop = `calc(50% + ${Math.sin(angle) * radius}px)`;
    } else if (dock === 'top') {
        const start = 50; const end = 130; const step = (end - start) / (total - 1);
        angle = (start + index * step) * (Math.PI / 180);
        baseLeft = `calc(50% + ${Math.cos(angle) * radius}px)`;
        baseTop = `calc(0% + ${centerOffset + Math.sin(angle) * radius}px)`;
    } else if (dock === 'bottom') {
        const start = 230; const end = 310; const step = (end - start) / (total - 1);
        angle = (start + index * step) * (Math.PI / 180);
        baseLeft = `calc(50% + ${Math.cos(angle) * radius}px)`;
        baseTop = `calc(100% + ${Math.abs(centerOffset) + Math.sin(angle) * radius}px)`;
    }

    // ANIMATION STATE CALCULATION
    let visibleX = '-50%';
    let visibleY = '-50%';
    let hiddenX = '-50%';
    let hiddenY = '-50%';
    let hiddenScale = 0.85; 
    let visibleScale = dock === 'center' ? 1 : 0.85;

    if (dock === 'center') {
        hiddenScale = 0;
    } else {
        if (dock === 'left') hiddenX = `calc(-50% - ${hideShift}px)`;
        if (dock === 'right') hiddenX = `calc(-50% + ${hideShift}px)`;
        if (dock === 'top') hiddenY = `calc(-50% - ${hideShift}px)`;
        if (dock === 'bottom') hiddenY = `calc(-50% + ${hideShift}px)`;
    }

    return {
        left: baseLeft,
        top: baseTop,
        visible: { x: visibleX, y: visibleY, scale: visibleScale, opacity: 1 },
        hidden: { x: hiddenX, y: hiddenY, scale: hiddenScale, opacity: dock === 'center' ? 0 : 0 } 
    };
  };

  return (
    <>
      {items.map((item, index) => {
        const isActive = activeItemId === item.id;
        const { left, top, visible, hidden } = getPosition(index, items.length, currentDock);
        const Icon = item.icon;
        const animateState = isHidden ? 'hidden' : 'visible';

        // Special Styling for Offline button
        const isSpecial = item.special;
        const activeColor = item.color || '#60a5fa';

        return (
          <motion.button
            key={item.id}
            initial="hidden"
            animate={animateState}
            variants={{ visible, hidden }}
            transition={{ type: 'spring', stiffness: 100, damping: 20, mass: 1, delay: index * 0.02 }} 
            onClick={() => onItemClick(item)}
            onHoverStart={onHoverStart} 
            onHoverEnd={onHoverEnd}
            className={`absolute z-60 flex flex-col items-center justify-center group outline-none`}
            style={{ 
                left, 
                top,
                color: isActive ? activeColor : (isSpecial ? '#64748b' : '#94a3b8'),
                pointerEvents: isHidden ? 'none' : 'auto'
            }}
          >
            <div 
                className={`
                    p-3 rounded-full backdrop-blur-md border border-white/10 shadow-lg 
                    transition-all duration-300 group-hover:bg-white/10 group-hover:scale-110
                    ${isActive ? 'bg-white/20 border-white/30' : (isSpecial ? 'bg-slate-800/80 border-slate-700' : 'bg-slate-900/60')}
                `}
                style={{
                    boxShadow: isActive ? `0 0 15px ${activeColor}50` : 'none',
                    borderColor: isActive ? activeColor : undefined
                }}
            >
              <Icon size={isMobile ? 16 : 20} />
            </div>
            
            <motion.span 
                className={`mt-1 text-[9px] font-bold tracking-widest uppercase transition-colors duration-300 ${isActive ? 'text-white' : 'text-slate-600 group-hover:text-slate-400'}`}
                animate={{ opacity: 1 }}
                style={{ color: isActive ? activeColor : undefined }}
            >
              {item.label}
            </motion.span>
          </motion.button>
        );
      })}
    </>
  );
};

export default OrbitMenu;