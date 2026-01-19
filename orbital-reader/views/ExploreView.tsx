
import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, Compass, Zap, Flame, Radio, Sparkles, Loader2, Globe } from 'lucide-react';
import { Language, Book } from '../types';
import { GoogleGenAI, Type } from "@google/genai";

interface ExploreViewProps {
    language: Language;
    onSelectBook: (book: Book) => void;
}

const ExploreView: React.FC<ExploreViewProps> = ({ language, onSelectBook }) => {
    const [searchQuery, setSearchQuery] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [searchResults, setSearchResults] = useState<any[] | null>(null);

    const t = {
        en: {
            placeholder: "Scan the universal archives for real books...",
            trending: "Archive Categories",
            featured: "Stellar Discoveries",
            results: "Neural Matches Found",
            signalStream: "Signal Stream",
            explore: "Universal Discovery",
            tags: ["Classic Sci-Fi", "Cyberpunk", "Dystopian", "Hard Science", "Space Opera", "Philosophy"],
            scanning: "Querying Global Databases..."
        },
        zh: {
            placeholder: "从全域档案库搜索真实书籍...",
            trending: "档案类别",
            featured: "恒星发现",
            results: "神经匹配结果",
            signalStream: "信号流",
            explore: "全域探索",
            tags: ["经典科幻", "赛博朋克", "反乌托邦", "硬核科学", "太空歌剧", "哲学"],
            scanning: "正在查询全球数据库..."
        }
    }[language];

    const defaultDiscoveries = [
        { id: 'real_1', title: "1984", author: "George Orwell", tags: ["Classic", "Dystopian"], color: "from-slate-700 to-slate-900", source: "Public Domain" },
        { id: 'real_2', title: "Frankenstein", author: "Mary Shelley", tags: ["Gothic", "Sci-Fi"], color: "from-emerald-900 to-black", source: "Project Gutenberg" },
        { id: 'real_3', title: "The Time Machine", author: "H.G. Wells", tags: ["Adventure", "Classic"], color: "from-amber-700 to-orange-900", source: "Open Library" }
    ];

    const handleSearch = async (e?: React.FormEvent) => {
        if (e) e.preventDefault();
        const query = searchQuery.trim();
        if (!query) {
            setSearchResults(null);
            return;
        }

        setIsLoading(true);
        try {
            const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
            const response = await ai.models.generateContent({
                model: "gemini-3-flash-preview",
                contents: `Find 4 REAL, existing world-famous books related to this query: "${query}". 
                           Focus on high-quality literature and famous classics. 
                           Return an array of JSON objects with real titles and authors.`,
                config: {
                    responseMimeType: "application/json",
                    responseSchema: {
                        type: Type.ARRAY,
                        items: {
                            type: Type.OBJECT,
                            properties: {
                                id: { type: Type.STRING },
                                title: { type: Type.STRING },
                                author: { type: Type.STRING },
                                tags: { type: Type.ARRAY, items: { type: Type.STRING } },
                                color: { type: Type.STRING, description: "Tailwind gradient like 'from-red-500 to-purple-600'" },
                                source: { type: Type.STRING, description: "A realistic source name like 'Project Gutenberg' or 'Neural Archive'" }
                            },
                            required: ["id", "title", "author", "tags", "color", "source"]
                        }
                    }
                }
            });

            const results = JSON.parse(response.text || "[]");
            setSearchResults(results);
        } catch (error) {
            console.error("Archive search failed:", error);
        } finally {
            setIsLoading(false);
        }
    };

    const displayBooks = searchResults || defaultDiscoveries;

    return (
        <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="w-full h-full overflow-y-auto px-6 md:px-12 lg:px-24 pt-12 pb-32 max-w-7xl mx-auto"
        >
            <div className="mb-12 text-center">
                <motion.div 
                    initial={{ y: 20, opacity: 0 }}
                    animate={{ y: 0, opacity: 1 }}
                    className="inline-flex items-center space-x-2 text-blue-400 mb-4 bg-blue-500/10 px-4 py-1 rounded-full border border-blue-500/20"
                >
                    <Globe size={14} className="animate-pulse" />
                    <span className="text-xs font-bold tracking-[0.3em] uppercase">{t.explore}</span>
                </motion.div>
                
                <form onSubmit={handleSearch} className="relative max-w-2xl mx-auto group">
                    <Search className={`absolute left-5 top-1/2 -translate-y-1/2 transition-colors ${isLoading ? 'text-blue-400 animate-pulse' : 'text-slate-500 group-focus-within:text-blue-400'}`} size={20} />
                    <input 
                        type="text"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        placeholder={t.placeholder}
                        className="w-full bg-slate-900/60 backdrop-blur-xl border border-slate-800 rounded-2xl py-4 pl-14 pr-6 text-slate-100 placeholder-slate-600 focus:outline-none focus:border-blue-500/50 focus:ring-4 focus:ring-blue-500/5 transition-all shadow-lg"
                    />
                    <div className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-3">
                        {isLoading && <Loader2 size={18} className="text-blue-400 animate-spin" />}
                        <div className={`w-1.5 h-1.5 bg-blue-500 rounded-full ${isLoading ? 'animate-ping' : ''}`}></div>
                    </div>
                </form>
            </div>

            <div className="mb-12">
                <div className="flex items-center space-x-2 mb-6">
                    <Flame size={18} className="text-orange-500" />
                    <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest">{t.trending}</h3>
                </div>
                <div className="flex flex-wrap gap-3">
                    {t.tags.map((tag, i) => (
                        <motion.button
                            key={tag}
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: i * 0.05 }}
                            onClick={() => {
                                setSearchQuery(tag);
                                setTimeout(() => handleSearch(), 10);
                            }}
                            whileHover={{ scale: 1.05, backgroundColor: 'rgba(59, 130, 246, 0.2)', borderColor: 'rgba(59, 130, 246, 0.4)' }}
                            className="px-4 py-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-400 text-sm font-medium transition-all"
                        >
                            #{tag}
                        </motion.button>
                    ))}
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                <div className="lg:col-span-2">
                    <div className="flex items-center space-x-2 mb-6">
                        <Sparkles size={18} className="text-yellow-400" />
                        <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest">
                            {isLoading ? t.scanning : (searchResults ? t.results : t.featured)}
                        </h3>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 min-h-[400px]">
                        <AnimatePresence mode="wait">
                            {isLoading ? (
                                <motion.div key="loading" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="col-span-full grid grid-cols-1 md:grid-cols-2 gap-6">
                                    {[1, 2, 3, 4].map(n => (
                                        <div key={n} className="aspect-video rounded-3xl bg-slate-900/50 animate-pulse border border-slate-800/50 flex flex-col items-center justify-center p-8 space-y-4">
                                            <div className="w-2/3 h-4 bg-slate-800 rounded"></div>
                                            <div className="w-1/2 h-3 bg-slate-800 rounded opacity-60"></div>
                                        </div>
                                    ))}
                                </motion.div>
                            ) : (
                                <motion.div key="results" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="col-span-full grid grid-cols-1 md:grid-cols-2 gap-6">
                                    {displayBooks.map((item, i) => (
                                        <motion.div
                                            key={item.id}
                                            initial={{ x: -20, opacity: 0 }}
                                            animate={{ x: 0, opacity: 1 }}
                                            transition={{ delay: i * 0.1 }}
                                            whileHover={{ y: -5 }}
                                            onClick={() => onSelectBook({ 
                                                id: item.id, 
                                                title: item.title, 
                                                author: item.author, 
                                                coverColor: item.color.startsWith('bg-') ? item.color : `bg-gradient-to-br ${item.color}`, 
                                                progress: 0 
                                            })}
                                            className="group cursor-pointer relative aspect-video rounded-3xl overflow-hidden shadow-2xl border border-white/5"
                                        >
                                            <div className={`absolute inset-0 ${item.color.startsWith('bg-') ? item.color : `bg-gradient-to-br ${item.color}`} opacity-60 transition-opacity group-hover:opacity-80`}></div>
                                            <div className="absolute inset-0 bg-slate-950/40 backdrop-blur-[1px] group-hover:backdrop-blur-none transition-all"></div>
                                            <div className="absolute top-4 left-4">
                                                <span className="text-[9px] font-bold text-white/40 uppercase tracking-widest bg-black/20 px-2 py-1 rounded-md">{item.source || 'Neural Link'}</span>
                                            </div>
                                            <div className="absolute bottom-0 left-0 right-0 p-6">
                                                <div className="flex gap-2 mb-2">
                                                    {item.tags.map((tag: string) => (
                                                        <span key={tag} className="text-[9px] font-bold bg-white/10 backdrop-blur-md px-2 py-0.5 rounded-full text-white/80">#{tag}</span>
                                                    ))}
                                                </div>
                                                <h4 className="text-xl font-bold text-white mb-1 group-hover:translate-x-1 transition-transform">{item.title}</h4>
                                                <p className="text-sm text-white/60 font-medium">{item.author}</p>
                                            </div>
                                        </motion.div>
                                    ))}
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </div>
                </div>

                <div className="space-y-6">
                    <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center space-x-2">
                            <Radio size={18} className="text-emerald-500 animate-pulse" />
                            <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest">Signal Stream</h3>
                        </div>
                    </div>
                    <div className="space-y-4">
                        {[
                            { id: 1, user: "Lib_Bot_01", content: "Successfully ingested 42 classic texts from Gutenberg.", time: "2m ago" },
                            { id: 2, user: "Archivist", content: "Encryption key for 'Brave New World' updated.", time: "15m ago" },
                            { id: 3, user: "Drifter_X", content: "Is the text for 'Snow Crash' complete yet?", time: "1h ago" }
                        ].map((signal, i) => (
                            <motion.div key={signal.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 + i * 0.1 }} className="p-4 rounded-2xl bg-slate-900/40 border border-slate-800/60 backdrop-blur-sm">
                                <div className="flex justify-between items-center mb-2">
                                    <span className="text-[10px] font-bold text-blue-400 uppercase tracking-wider">{signal.user}</span>
                                    <span className="text-[10px] text-slate-600 font-mono">{signal.time}</span>
                                </div>
                                <p className="text-sm text-slate-300 leading-relaxed italic">"{signal.content}"</p>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </div>
        </motion.div>
    );
};

export default ExploreView;
