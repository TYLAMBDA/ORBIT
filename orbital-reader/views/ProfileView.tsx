import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { User, Language } from '../types';
import { User as UserIcon, BookOpen, PenTool, Clock, Edit2, Key, Save, X, LogOut, Mail } from 'lucide-react';

interface ProfileViewProps {
    user: User | null;
    language: Language;
    onUpdateUser: (updatedUser: User) => void;
    onLogout: () => void;
}

const ProfileView: React.FC<ProfileViewProps> = ({ user, language, onUpdateUser, onLogout }) => {
    const [isEditingPass, setIsEditingPass] = useState(false);
    const [showAvatarPicker, setShowAvatarPicker] = useState(false);
    const [tempPass, setTempPass] = useState('');

    const avatarColors = [
        'bg-gradient-to-br from-blue-500 to-cyan-400',
        'bg-gradient-to-br from-purple-500 to-indigo-600',
        'bg-gradient-to-br from-rose-500 to-orange-400',
        'bg-gradient-to-br from-emerald-500 to-teal-400',
        'bg-gradient-to-br from-slate-600 to-slate-800',
        'bg-gradient-to-br from-amber-500 to-red-500',
    ];

    if (!user) return null;

    const t = {
        en: {
            changePass: "Change Password",
            newPass: "New Password",
            save: "Save",
            cancel: "Cancel",
            logout: "Disconnect",
            stats: { read: "Books Read", published: "Published", time: "Hours Read" },
            headers: { history: "Reading History", works: "Published Works" },
            alertPass: "Password updated successfully!"
        },
        zh: {
            changePass: "修改密码",
            newPass: "输入新密码",
            save: "保存",
            cancel: "取消",
            logout: "退出登录",
            stats: { read: "已读数量", published: "发布数量", time: "阅读时长" },
            headers: { history: "阅读足迹", works: "我的作品" },
            alertPass: "密码已更新！"
        }
    }[language];

    const handleAvatarChange = (colorClass: string) => {
        onUpdateUser({ ...user, avatar: colorClass });
        setShowAvatarPicker(false);
    };

    const handlePassChange = (e: React.FormEvent) => {
        e.preventDefault();
        setIsEditingPass(false);
        setTempPass('');
        alert(t.alertPass);
    };

    return (
        <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="w-full h-full overflow-y-auto p-6 md:p-12 lg:p-16 max-w-6xl mx-auto pb-32"
        >
            {/* Header / Identity Card */}
            <div className="bg-slate-900/40 border border-slate-800/60 rounded-3xl p-8 md:p-10 mb-8 flex flex-col md:flex-row items-center md:items-start gap-8 md:gap-12 backdrop-blur-sm">
                
                {/* Avatar Section */}
                <div className="relative group shrink-0">
                    <div className={`w-32 h-32 md:w-40 md:h-40 rounded-full ${user.avatar} shadow-[0_0_40px_rgba(0,0,0,0.3)] flex items-center justify-center text-4xl md:text-5xl font-bold text-white uppercase border-4 border-slate-900`}>
                        {user.username.substring(0,2)}
                    </div>
                    <button 
                        onClick={() => setShowAvatarPicker(!showAvatarPicker)}
                        className="absolute bottom-1 right-1 bg-slate-800 p-2.5 rounded-full border border-slate-600 hover:bg-blue-600 hover:border-blue-500 text-slate-300 hover:text-white transition-all shadow-lg"
                    >
                        <Edit2 size={16} />
                    </button>
                    
                    {/* Picker Popover */}
                    {showAvatarPicker && (
                        <div className="absolute top-full left-1/2 -translate-x-1/2 mt-4 p-3 bg-slate-800/95 backdrop-blur rounded-2xl border border-slate-700 shadow-2xl flex gap-2 z-50 animate-in fade-in zoom-in-95 duration-200">
                            {avatarColors.map((color, idx) => (
                                <button
                                    key={idx}
                                    onClick={() => handleAvatarChange(color)}
                                    className={`w-8 h-8 rounded-full ${color} hover:scale-110 transition-transform ring-2 ring-offset-2 ring-offset-slate-800 ring-transparent hover:ring-white/50`}
                                />
                            ))}
                        </div>
                    )}
                </div>

                {/* Info & Actions */}
                <div className="flex-1 text-center md:text-left space-y-3 w-full">
                    <h1 className="text-3xl md:text-5xl font-bold text-slate-100">{user.username}</h1>
                    <div className="flex items-center justify-center md:justify-start text-slate-400 font-mono text-sm space-x-2">
                        <Mail size={14} /> <span>{user.email}</span>
                    </div>
                    
                    <div className="pt-6 flex flex-wrap items-center justify-center md:justify-start gap-3">
                        {!isEditingPass ? (
                            <>
                                <button 
                                    onClick={() => setIsEditingPass(true)}
                                    className="flex items-center px-4 py-2.5 bg-slate-800 hover:bg-slate-700 rounded-xl text-sm font-medium text-slate-300 transition-colors border border-slate-700"
                                >
                                    <Key size={16} className="mr-2" /> {t.changePass}
                                </button>
                                <button 
                                    onClick={onLogout}
                                    className="flex items-center px-4 py-2.5 bg-red-500/10 hover:bg-red-500/20 border border-red-500/20 text-red-400 rounded-xl text-sm font-medium transition-colors"
                                >
                                    <LogOut size={16} className="mr-2" /> {t.logout}
                                </button>
                            </>
                        ) : (
                            <form onSubmit={handlePassChange} className="flex items-center gap-2 animate-in fade-in slide-in-from-left-4 w-full md:w-auto">
                                <div className="relative flex-1 md:flex-initial">
                                    <Key size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" />
                                    <input 
                                        type="password"
                                        value={tempPass}
                                        onChange={(e) => setTempPass(e.target.value)}
                                        placeholder={t.newPass}
                                        className="w-full md:w-48 bg-slate-950 border border-slate-700 rounded-xl pl-9 pr-3 py-2.5 text-sm text-white focus:outline-none focus:border-blue-500 transition-all"
                                        autoFocus
                                    />
                                </div>
                                <button type="submit" className="p-2.5 bg-blue-600 rounded-xl text-white hover:bg-blue-500 shadow-lg shadow-blue-500/20"><Save size={18} /></button>
                                <button onClick={() => setIsEditingPass(false)} className="p-2.5 bg-slate-800 rounded-xl text-slate-400 hover:text-white hover:bg-slate-700 border border-slate-700"><X size={18} /></button>
                            </form>
                        )}
                    </div>
                </div>
            </div>

            {/* Stats Overview */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 mb-8">
                {[
                    { icon: Clock, label: t.stats.time, val: user.stats.totalReadingHours + 'h', color: 'text-blue-400', bg: 'bg-blue-500/10' },
                    { icon: BookOpen, label: t.stats.read, val: user.stats.booksRead.length, color: 'text-emerald-400', bg: 'bg-emerald-500/10' },
                    { icon: PenTool, label: t.stats.published, val: user.stats.booksPublished.length, color: 'text-purple-400', bg: 'bg-purple-500/10' }
                ].map((stat, i) => (
                    <div key={i} className="bg-slate-900/40 border border-slate-800/60 p-6 rounded-2xl flex items-center space-x-4">
                        <div className={`p-3.5 rounded-xl ${stat.bg} ${stat.color}`}>
                            <stat.icon size={24} />
                        </div>
                        <div>
                            <div className="text-2xl font-bold text-slate-100">{stat.val}</div>
                            <div className="text-xs font-bold text-slate-500 uppercase tracking-widest">{stat.label}</div>
                        </div>
                    </div>
                ))}
            </div>

            {/* Content Lists */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="space-y-4">
                    <h3 className="text-lg font-semibold text-slate-300 flex items-center">
                        <BookOpen size={18} className="mr-2 text-slate-500" /> {t.headers.history}
                    </h3>
                    <div className="bg-slate-900/30 border border-slate-800/50 rounded-2xl overflow-hidden min-h-[200px]">
                        {user.stats.booksRead.length > 0 ? (
                            <ul className="divide-y divide-slate-800/50">
                                {user.stats.booksRead.map((book, i) => (
                                    <li key={i} className="flex items-center p-4 hover:bg-white/5 transition-colors">
                                        <span className="w-2 h-2 bg-emerald-500 rounded-full mr-3 shrink-0"></span>
                                        <span className="text-slate-300 text-sm truncate">{book}</span>
                                    </li>
                                ))}
                            </ul>
                        ) : (
                            <div className="h-full flex items-center justify-center text-slate-600 text-sm italic p-6">Nothing here yet.</div>
                        )}
                    </div>
                </div>

                <div className="space-y-4">
                    <h3 className="text-lg font-semibold text-slate-300 flex items-center">
                        <PenTool size={18} className="mr-2 text-slate-500" /> {t.headers.works}
                    </h3>
                    <div className="bg-slate-900/30 border border-slate-800/50 rounded-2xl overflow-hidden min-h-[200px]">
                        {user.stats.booksPublished.length > 0 ? (
                            <ul className="divide-y divide-slate-800/50">
                                {user.stats.booksPublished.map((book, i) => (
                                    <li key={i} className="flex items-center p-4 hover:bg-white/5 transition-colors">
                                        <span className="w-2 h-2 bg-purple-500 rounded-full mr-3 shrink-0"></span>
                                        <span className="text-slate-300 text-sm truncate">{book}</span>
                                    </li>
                                ))}
                            </ul>
                        ) : (
                            <div className="h-full flex items-center justify-center text-slate-600 text-sm italic p-6">No works published.</div>
                        )}
                    </div>
                </div>
            </div>
        </motion.div>
    );
};

export default ProfileView;
