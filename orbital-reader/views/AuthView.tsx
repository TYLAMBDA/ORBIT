import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Mail, Lock, User as UserIcon, ArrowRight, AlertCircle, LogIn, UserPlus, X } from 'lucide-react';
import { Language, User } from '../types';

interface AuthViewProps {
    language: Language;
    onLoginSuccess: (user: User) => void;
    onClose: () => void;
}

const AuthView: React.FC<AuthViewProps> = ({ language, onLoginSuccess, onClose }) => {
    const [viewMode, setViewMode] = useState<'login' | 'register'>('login');
    
    // Form States
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [username, setUsername] = useState('');
    const [error, setError] = useState<string | null>(null);

    const t = {
        en: {
            loginTitle: "Identity Verification",
            registerTitle: "New Resident Registration",
            email: "Email Address",
            password: "Password",
            username: "Codename",
            loginBtn: "Access System",
            registerBtn: "Initialize Identity",
            switchRegister: "No Identity? Request Access",
            switchLogin: "Identity Exists? Verify",
            errorCredentials: "Access Denied. Try: 1@gmail.com / 1",
            errorFields: "All parameters required for initialization."
        },
        zh: {
            loginTitle: "身份验证",
            registerTitle: "新用户注册",
            email: "电子邮箱",
            password: "访问密钥",
            username: "用户代号",
            loginBtn: "进入系统",
            registerBtn: "建立档案",
            switchRegister: "没有账号？注册新身份",
            switchLogin: "已有账号？立即登录",
            errorCredentials: "验证失败。测试账号: 1@gmail.com / 1",
            errorFields: "请补全所有必填信息。"
        }
    }[language];

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);

        if (viewMode === 'register') {
            // Register Validation
            if (!email || !password || !username) {
                setError(t.errorFields);
                return;
            }
            // Mock Register Success -> Auto Login
            const newUser: User = {
                username: username,
                email: email,
                avatar: 'bg-gradient-to-br from-emerald-500 to-teal-600',
                stats: {
                    totalReadingHours: 0,
                    booksRead: [],
                    booksPublished: []
                }
            };
            onLoginSuccess(newUser);

        } else {
            // Login Validation
            if (email === '1@gmail.com' && password === '1') {
                const mockUser: User = {
                    username: 'Traveller_01',
                    email: '1@gmail.com',
                    avatar: 'bg-gradient-to-br from-blue-500 to-indigo-600',
                    stats: {
                        totalReadingHours: 142.5,
                        booksRead: ['The Three-Body Problem', 'Dune', 'Neuromancer', 'Foundation'],
                        booksPublished: ['My Notes on Mars', 'Orbital Mechanics 101']
                    }
                };
                onLoginSuccess(mockUser);
            } else {
                setError(t.errorCredentials);
            }
        }
    };

    const toggleMode = () => {
        setError(null);
        setViewMode(viewMode === 'login' ? 'register' : 'login');
    };

    return (
        <div 
            className="w-full h-full flex items-center justify-center p-4 cursor-pointer"
            onClick={onClose} // Click outside to close
        >
            <motion.div 
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4 }}
                onClick={(e) => e.stopPropagation()} // Prevent close when clicking inside the card
                className="relative w-full max-w-md bg-slate-900/80 backdrop-blur-2xl border border-slate-700/50 rounded-3xl overflow-hidden shadow-2xl cursor-auto"
            >
                {/* Header Decoration */}
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-blue-500 via-purple-500 to-blue-500 opacity-70"></div>
                
                {/* Close Button */}
                <button 
                    onClick={onClose}
                    className="absolute top-4 right-4 p-2 text-slate-500 hover:text-white hover:bg-slate-800 rounded-full transition-colors z-10"
                >
                    <X size={20} />
                </button>

                <div className="p-8 md:p-10">
                    <div className="flex justify-center mb-8">
                        <div className="p-4 bg-slate-800 rounded-full shadow-inner border border-slate-700">
                            {viewMode === 'login' ? <LogIn className="text-blue-400" size={32}/> : <UserPlus className="text-purple-400" size={32}/>}
                        </div>
                    </div>

                    <h2 className="text-2xl font-bold text-center text-white mb-8 tracking-wide">
                        {viewMode === 'login' ? t.loginTitle : t.registerTitle}
                    </h2>

                    <form onSubmit={handleSubmit} className="space-y-5">
                        <AnimatePresence mode='popLayout'>
                            {viewMode === 'register' && (
                                <motion.div 
                                    initial={{ opacity: 0, height: 0, overflow: 'hidden' }}
                                    animate={{ opacity: 1, height: 'auto' }}
                                    exit={{ opacity: 0, height: 0 }}
                                    className="space-y-2"
                                >
                                    <label className="text-xs font-bold text-slate-500 uppercase tracking-wider ml-1">{t.username}</label>
                                    <div className="relative group">
                                        <UserIcon className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500 group-focus-within:text-blue-400 transition-colors" size={18} />
                                        <input 
                                            type="text" 
                                            value={username}
                                            onChange={(e) => setUsername(e.target.value)}
                                            className="w-full bg-slate-950/50 border border-slate-700/80 rounded-xl py-3.5 pl-11 pr-4 text-slate-100 placeholder-slate-700 focus:outline-none focus:border-blue-500/50 focus:bg-slate-900 transition-all"
                                            placeholder="John Doe"
                                        />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>

                        <div className="space-y-2">
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-wider ml-1">{t.email}</label>
                            <div className="relative group">
                                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500 group-focus-within:text-blue-400 transition-colors" size={18} />
                                <input 
                                    type="email" 
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="w-full bg-slate-950/50 border border-slate-700/80 rounded-xl py-3.5 pl-11 pr-4 text-slate-100 placeholder-slate-700 focus:outline-none focus:border-blue-500/50 focus:bg-slate-900 transition-all"
                                    placeholder="name@example.com"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-wider ml-1">{t.password}</label>
                            <div className="relative group">
                                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500 group-focus-within:text-blue-400 transition-colors" size={18} />
                                <input 
                                    type="password" 
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className="w-full bg-slate-950/50 border border-slate-700/80 rounded-xl py-3.5 pl-11 pr-4 text-slate-100 placeholder-slate-700 focus:outline-none focus:border-blue-500/50 focus:bg-slate-900 transition-all"
                                    placeholder="••••••••"
                                />
                            </div>
                        </div>

                        <AnimatePresence>
                            {error && (
                                <motion.div 
                                    initial={{ opacity: 0, y: -10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0, y: -10 }}
                                    className="flex items-center text-red-400 text-sm bg-red-500/10 border border-red-500/20 p-3 rounded-xl"
                                >
                                    <AlertCircle size={16} className="mr-2 flex-shrink-0" />
                                    {error}
                                </motion.div>
                            )}
                        </AnimatePresence>

                        <button 
                            type="submit"
                            className="w-full mt-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold py-4 rounded-xl shadow-lg shadow-blue-900/20 transition-all transform hover:scale-[1.01] active:scale-[0.99] flex items-center justify-center group"
                        >
                            {viewMode === 'login' ? t.loginBtn : t.registerBtn}
                            <ArrowRight size={18} className="ml-2 opacity-70 group-hover:translate-x-1 transition-transform" />
                        </button>
                    </form>
                </div>

                <div className="bg-slate-950/30 p-4 text-center border-t border-slate-800">
                    <button 
                        onClick={toggleMode}
                        className="text-slate-400 hover:text-white text-sm transition-colors font-medium"
                    >
                        {viewMode === 'login' ? t.switchRegister : t.switchLogin}
                    </button>
                </div>
            </motion.div>
        </div>
    );
};

export default AuthView;
