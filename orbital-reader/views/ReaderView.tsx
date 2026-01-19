
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Share2, Type, Bookmark, Loader2, Sparkles, Download, CheckCircle2 } from 'lucide-react';
import { DockPosition, Language, Book } from '../types';
import { GoogleGenAI, Type as SchemaType } from "@google/genai";
import { OrbitalDB } from '../services/db';

interface ReaderViewProps {
    dockPosition: DockPosition;
    language: Language;
    book: Book | null;
}

const ReaderView: React.FC<ReaderViewProps> = ({ dockPosition, language, book }) => {
    const [content, setContent] = useState<string[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [downloadStep, setDownloadStep] = useState(0);
    const [downloadProgress, setDownloadProgress] = useState(0);

    useEffect(() => {
        if (!book) return;

        const cached = OrbitalDB.getBookContent(book.id);
        if (cached) {
            setContent(cached);
        } else {
            initiateDownload();
        }
    }, [book]);

    const initiateDownload = async () => {
        if (!book) return;
        setIsLoading(true);
        setDownloadStep(0);
        setDownloadProgress(0);

        // Simulated high-end download sequence
        const steps = [
            "Connecting to Global Archive...",
            "Validating Identity Tokens...",
            "Locating Data Shards...",
            "Streaming Text Content...",
            "Synthesizing Neural Interface..."
        ];

        for (let i = 0; i < steps.length; i++) {
            setDownloadStep(i);
            // Speed up the first few steps, slow down for text retrieval
            const duration = i === 3 ? 3000 : 800; 
            
            // Increment progress smoothly
            const startProgress = (i / steps.length) * 100;
            const endProgress = ((i + 1) / steps.length) * 100;
            
            const interval = setInterval(() => {
                setDownloadProgress(prev => {
                    if (prev < endProgress) return prev + 1;
                    clearInterval(interval);
                    return prev;
                });
            }, duration / (endProgress - startProgress));

            if (i === 3) {
                // This is where we actually call the AI to "download" the text
                await fetchRealBookText();
            } else {
                await new Promise(r => setTimeout(r, duration));
            }
            clearInterval(interval);
        }

        setDownloadProgress(100);
        setTimeout(() => setIsLoading(false), 500);
    };

    const fetchRealBookText = async () => {
        if (!book) return;
        try {
            const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
            const response = await ai.models.generateContent({
                model: "gemini-3-flash-preview",
                contents: `Retrieve the actual, verbatim opening text (first 4-5 paragraphs) of the real book: "${book.title}" by ${book.author}. 
                           If the book is under copyright, provide a very high-quality, 100% accurate stylistic summary that captures the exact narrative voice. 
                           If it is Public Domain (e.g. Orwell, Shelley, Wells), provide the REAL text.`,
                config: {
                    responseMimeType: "application/json",
                    responseSchema: {
                        type: SchemaType.ARRAY,
                        items: { type: SchemaType.STRING }
                    }
                }
            });

            const paragraphs = JSON.parse(response.text || "[]");
            setContent(paragraphs);
            OrbitalDB.saveBookContent(book.id, paragraphs);
        } catch (error) {
            console.error("Archive retrieval failed:", error);
            setContent(["Error: Connection to universal archives severed. Check your uplink."]);
        }
    };

    if (!book) return null;

    const t = {
        en: { 
            chapter: "Chapter 1", 
            synth: "Neural Link Verified",
            steps: ["Connecting...", "Validating...", "Locating...", "Downloading...", "Finalizing..."]
        },
        zh: { 
            chapter: "第一章", 
            synth: "神经连接已确认",
            steps: ["连接中...", "验证中...", "检索中...", "下载中...", "完成中..."]
        }
    }[language];

    const containerPadding = "p-6 md:p-12 lg:p-16";

    return (
        <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className={`w-full h-full overflow-y-auto ${containerPadding} max-w-4xl mx-auto pb-32`}
        >
            <AnimatePresence mode="wait">
                {isLoading ? (
                    <motion.div 
                        key="loading"
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="flex flex-col items-center justify-center py-32 space-y-8"
                    >
                        <div className="relative">
                            <div className="w-32 h-32 rounded-full border-2 border-slate-800 flex items-center justify-center">
                                <Download size={40} className="text-blue-500 animate-bounce" />
                            </div>
                            <svg className="absolute inset-0 w-32 h-32 -rotate-90">
                                <circle
                                    cx="64" cy="64" r="62"
                                    fill="transparent"
                                    stroke="currentColor"
                                    strokeWidth="4"
                                    className="text-blue-500/20"
                                />
                                <motion.circle
                                    cx="64" cy="64" r="62"
                                    fill="transparent"
                                    stroke="currentColor"
                                    strokeWidth="4"
                                    strokeDasharray={390}
                                    animate={{ strokeDashoffset: 390 - (390 * downloadProgress) / 100 }}
                                    className="text-blue-500"
                                />
                            </svg>
                        </div>
                        <div className="text-center space-y-2">
                            <p className="text-slate-100 font-bold tracking-widest uppercase text-sm">
                                {t.steps[downloadStep]}
                            </p>
                            <p className="text-slate-500 font-mono text-xs">{downloadProgress}% Data Shards Acquired</p>
                        </div>
                    </motion.div>
                ) : (
                    <motion.div 
                        key="content"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="space-y-0"
                    >
                        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 md:mb-12 border-b border-slate-800 pb-6">
                            <div>
                                <div className="flex items-center gap-2 mb-2">
                                    <span className="text-blue-400 text-xs font-bold tracking-widest uppercase">{t.chapter}</span>
                                    <div className="w-1 h-1 bg-slate-700 rounded-full"></div>
                                    <span className="text-emerald-500 text-[10px] font-mono flex items-center gap-1 uppercase tracking-tighter">
                                        <CheckCircle2 size={10} /> {t.synth}
                                    </span>
                                </div>
                                <h1 className="text-3xl md:text-5xl font-serif text-slate-100 leading-tight mb-2">{book.title}</h1>
                                <p className="text-slate-400 italic font-medium">{book.author}</p>
                            </div>
                            <div className="flex space-x-4 mt-4 md:mt-0 text-slate-500">
                                <button className="hover:text-blue-400 transition"><Type size={18} /></button>
                                <button className="hover:text-blue-400 transition"><Bookmark size={18} /></button>
                                <button className="hover:text-blue-400 transition"><Share2 size={18} /></button>
                            </div>
                        </div>

                        <div className="space-y-8 md:space-y-10">
                            {content.map((text, i) => (
                                <motion.p 
                                    key={i}
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ delay: i * 0.1 }}
                                    className="text-lg md:text-xl leading-relaxed text-slate-300 font-serif first-letter:text-3xl first-letter:font-bold first-letter:text-blue-400"
                                >
                                    {text}
                                </motion.p>
                            ))}
                        </div>

                        <div className="mt-20 py-8 border-t border-slate-900 flex justify-between items-center text-[10px] font-mono text-slate-600 tracking-[0.3em] uppercase">
                            <span>End of Fragment 1.0</span>
                            <span className="text-blue-900/40">Neural_Cache_Verified</span>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </motion.div>
    );
};

export default ReaderView;
