import React from 'react';
import { motion } from 'framer-motion';
import { DockPosition, Language } from '../types';
import { ArrowDown, ArrowLeft, ArrowRight, ArrowUp, Monitor, Shield, Bell, EyeOff, MousePointerClick, Languages, Radio } from 'lucide-react';

interface SettingsViewProps {
    preferredDock: DockPosition;
    onDockChange: (dock: DockPosition) => void;
    currentDockPosition: DockPosition;
    autoHide: boolean;
    onAutoHideChange: (val: boolean) => void;
    edgeNav: boolean;
    onEdgeNavChange: (val: boolean) => void;
    language: Language;
    onLanguageChange: (lang: Language) => void;
}

const SettingsView: React.FC<SettingsViewProps> = ({ 
    preferredDock, onDockChange, currentDockPosition,
    autoHide, onAutoHideChange,
    edgeNav, onEdgeNavChange,
    language, onLanguageChange
}) => {
    
    const t = {
        en: {
            title: "Settings",
            interface: "Interface",
            dockPos: "Dock Anchor",
            dockDesc: "Choose the primary anchor point.",
            dockDescOmni: "Omni-Wake active: Dock is accessible from all sides.",
            behavior: "Behavior",
            autoHide: "Auto-hide Dock",
            autoHideDesc: "Automatically hide the orb when not in use. Hover edge to reveal.",
            edgeNav: "Omni-Directional Wake",
            edgeNavDesc: "Allow the dock to be summoned from any screen edge.",
            general: "General",
            language: "Language",
            privacy: "Privacy & Data",
            notifications: "Notifications",
            top: "Top",
            bottom: "Bottom",
            left: "Left",
            right: "Right"
        },
        zh: {
            title: "设置",
            interface: "界面布局",
            dockPos: "导航停靠锚点",
            dockDesc: "选择导航球的主要停靠位置。",
            dockDescOmni: "全向灵动唤醒已激活：导航球可从屏幕任意边缘唤出。",
            behavior: "交互行为",
            autoHide: "自动隐藏导航球",
            autoHideDesc: "不使用时自动隐藏，鼠标靠近边缘时显示。",
            edgeNav: "全向灵动唤醒",
            edgeNavDesc: "允许从屏幕的上下左右任意边缘呼出导航球。",
            general: "常规",
            language: "语言",
            privacy: "隐私与数据",
            notifications: "通知",
            top: "顶部",
            bottom: "底部",
            left: "左侧",
            right: "右侧"
        }
    }[language];

    // Responsive Padding
    const containerPadding = "p-6 md:p-12 lg:p-16";

    // Helper to determine button style
    const getButtonStyle = (pos: DockPosition) => {
        if (edgeNav) {
            return 'bg-blue-900/80 border-blue-500 text-blue-100 shadow-[0_0_15px_rgba(37,99,235,0.4)]';
        }
        
        if (preferredDock === pos) {
            return 'bg-blue-600/20 border-blue-500 text-white shadow-[0_0_20px_rgba(37,99,235,0.3)]';
        }
        return 'bg-slate-800 border-slate-700 text-slate-400 hover:bg-slate-800/80';
    };

    return (
        <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.4 }}
            className={`w-full h-full overflow-y-auto ${containerPadding} max-w-6xl mx-auto pb-32`}
        >
            <h2 className="text-3xl md:text-4xl font-bold text-slate-100 mb-8">{t.title}</h2>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-8">
                {/* Interface Settings */}
                <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-2xl p-6 md:p-8 space-y-8">
                    {/* Position */}
                    <div>
                        <div className="flex items-center space-x-3 mb-6">
                            <Monitor className="text-blue-400" />
                            <h3 className="text-xl font-semibold text-slate-200">{t.interface}</h3>
                        </div>
                        <label className="block text-sm font-medium text-slate-400 mb-4 uppercase tracking-wider flex justify-between">
                            <span>{t.dockPos}</span>
                            {edgeNav && <span className="text-blue-400 text-xs flex items-center"><Radio size={12} className="mr-1 animate-pulse"/> Active Everywhere</span>}
                        </label>
                        <div className="grid grid-cols-2 gap-4">
                            <button 
                                onClick={() => !edgeNav && onDockChange('top')}
                                className={`flex items-center justify-center space-x-2 p-3 md:p-4 rounded-xl border transition-all duration-300 text-sm md:text-base ${getButtonStyle('top')} ${edgeNav ? 'cursor-default' : 'cursor-pointer'}`}
                            >
                                <ArrowUp size={18} /> <span>{t.top}</span>
                            </button>
                            <button 
                                onClick={() => !edgeNav && onDockChange('bottom')}
                                className={`flex items-center justify-center space-x-2 p-3 md:p-4 rounded-xl border transition-all duration-300 text-sm md:text-base ${getButtonStyle('bottom')} ${edgeNav ? 'cursor-default' : 'cursor-pointer'}`}
                            >
                                <ArrowDown size={18} /> <span>{t.bottom}</span>
                            </button>
                            <button 
                                onClick={() => !edgeNav && onDockChange('left')}
                                className={`flex items-center justify-center space-x-2 p-3 md:p-4 rounded-xl border transition-all duration-300 text-sm md:text-base ${getButtonStyle('left')} ${edgeNav ? 'cursor-default' : 'cursor-pointer'}`}
                            >
                                <ArrowLeft size={18} /> <span>{t.left}</span>
                            </button>
                            <button 
                                onClick={() => !edgeNav && onDockChange('right')}
                                className={`flex items-center justify-center space-x-2 p-3 md:p-4 rounded-xl border transition-all duration-300 text-sm md:text-base ${getButtonStyle('right')} ${edgeNav ? 'cursor-default' : 'cursor-pointer'}`}
                            >
                                <ArrowRight size={18} /> <span>{t.right}</span>
                            </button>
                        </div>
                        <p className={`text-xs mt-4 transition-colors ${edgeNav ? 'text-blue-300' : 'text-slate-500'}`}>
                            {edgeNav ? t.dockDescOmni : t.dockDesc}
                        </p>
                    </div>

                     {/* Language */}
                     <div>
                        <div className="flex items-center space-x-3 mb-4">
                            <Languages className="text-pink-400" />
                            <h3 className="text-xl font-semibold text-slate-200">{t.language}</h3>
                        </div>
                         <div className="flex space-x-4">
                            <button 
                                onClick={() => onLanguageChange('en')}
                                className={`flex-1 p-3 rounded-lg border text-sm font-medium transition-colors ${language === 'en' ? 'bg-slate-700 border-slate-500 text-white' : 'bg-slate-800 border-slate-700 text-slate-400 hover:bg-slate-700'}`}
                            >
                                English
                            </button>
                            <button 
                                onClick={() => onLanguageChange('zh')}
                                className={`flex-1 p-3 rounded-lg border text-sm font-medium transition-colors ${language === 'zh' ? 'bg-slate-700 border-slate-500 text-white' : 'bg-slate-800 border-slate-700 text-slate-400 hover:bg-slate-700'}`}
                            >
                                中文 (Chinese)
                            </button>
                         </div>
                    </div>
                </div>

                <div className="space-y-4 md:space-y-8">
                    {/* Behavior Settings */}
                    <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-2xl p-6 md:p-8">
                         <div className="flex items-center space-x-3 mb-6">
                            <MousePointerClick className="text-purple-400" />
                            <h3 className="text-xl font-semibold text-slate-200">{t.behavior}</h3>
                        </div>
                        
                        <div className="space-y-8">
                            {/* Auto Hide Toggle */}
                            <div className="flex items-start justify-between">
                                <div className="pr-4">
                                    <h4 className="text-base font-medium text-slate-300 flex items-center">
                                        <EyeOff size={16} className="mr-2" /> {t.autoHide}
                                    </h4>
                                    <p className="text-xs text-slate-500 mt-1">{t.autoHideDesc}</p>
                                </div>
                                <button 
                                    onClick={() => onAutoHideChange(!autoHide)}
                                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${autoHide ? 'bg-blue-600' : 'bg-slate-700'}`}
                                >
                                    <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${autoHide ? 'translate-x-6' : 'translate-x-1'}`} />
                                </button>
                            </div>

                             {/* Omni-Wake Toggle (Dependent on Auto-Hide) */}
                             <div className={`flex items-start justify-between transition-opacity duration-300 ${!autoHide ? 'opacity-50 pointer-events-none' : 'opacity-100'}`}>
                                <div className="pr-4">
                                    <h4 className="text-base font-medium text-slate-300 flex items-center">
                                        <Radio size={16} className="mr-2" /> {t.edgeNav}
                                    </h4>
                                    <p className="text-xs text-slate-500 mt-1">{t.edgeNavDesc}</p>
                                </div>
                                <button 
                                    onClick={() => onEdgeNavChange(!edgeNav)}
                                    disabled={!autoHide}
                                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${edgeNav && autoHide ? 'bg-purple-600' : 'bg-slate-700'}`}
                                >
                                    <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${edgeNav && autoHide ? 'translate-x-6' : 'translate-x-1'}`} />
                                </button>
                            </div>
                        </div>
                    </div>

                    {/* Dummy Privacy Settings */}
                     <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-2xl p-6 md:p-8 opacity-60 pointer-events-none">
                        <div className="flex items-center space-x-3 mb-6">
                            <Shield className="text-emerald-400" />
                            <h3 className="text-xl font-semibold text-slate-200">{t.privacy}</h3>
                        </div>
                        <div className="space-y-4">
                            <div className="h-2 bg-slate-800 rounded w-3/4"></div>
                            <div className="h-2 bg-slate-800 rounded w-1/2"></div>
                        </div>
                    </div>
                </div>
            </div>
        </motion.div>
    );
};

export default SettingsView;
