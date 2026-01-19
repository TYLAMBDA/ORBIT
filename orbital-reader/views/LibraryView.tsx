
import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Book as BookIcon, Star, Clock, Trash2 } from 'lucide-react';
import { Book, DockPosition, Language } from '../types';
import { OrbitalDB } from '../services/db';

interface LibraryViewProps {
    onSelectBook: (book: Book) => void;
    dockPosition: DockPosition;
    language: Language;
}

const LibraryView: React.FC<LibraryViewProps> = ({ onSelectBook, dockPosition, language }) => {
    const [books, setBooks] = useState<Book[]>([]);

    useEffect(() => {
        setBooks(OrbitalDB.getBooks());
    }, []);
    
    const handleDelete = (e: React.MouseEvent, id: string) => {
        e.stopPropagation();
        OrbitalDB.removeBook(id);
        setBooks(prev => prev.filter(b => b.id !== id));
    };

    const t = {
        en: { title: "My Library", subtitle: `${books.length} Active Nodes` },
        zh: { title: "我的书库", subtitle: `${books.length} 个活跃节点` }
    }[language];

    const containerPadding = "p-6 md:p-12 lg:p-16";

    return (
        <motion.div 
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.98 }}
            className={`w-full h-full overflow-y-auto ${containerPadding} max-w-7xl mx-auto pb-32`}
        >
            <div className="flex justify-between items-end mb-12 border-b border-slate-800 pb-6">
                <div>
                    <h2 className="text-3xl md:text-5xl font-bold text-slate-100 tracking-tight">{t.title}</h2>
                    <p className="text-sm md:text-base text-slate-500 mt-2 font-mono uppercase tracking-widest">{t.subtitle}</p>
                </div>
                <div className="flex space-x-6 text-slate-500">
                    <button className="hover:text-blue-400 transition"><Clock size={24} /></button>
                    <button className="hover:text-yellow-400 transition"><Star size={24} /></button>
                </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                <AnimatePresence>
                    {books.map((book, i) => (
                        <motion.div
                            key={book.id}
                            layout
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.9, transition: { duration: 0.2 } }}
                            transition={{ delay: 0.05 * i }}
                            onClick={() => onSelectBook(book)}
                            className="group relative aspect-[3/4] rounded-2xl overflow-hidden cursor-pointer shadow-xl border border-white/5"
                        >
                            <div className={`absolute inset-0 ${book.coverColor} opacity-70 group-hover:opacity-90 transition-opacity`}></div>
                            <div className="absolute inset-0 bg-gradient-to-t from-black via-black/20 to-transparent"></div>
                            
                            <div className="absolute bottom-0 left-0 right-0 p-6">
                                <h3 className="text-xl font-bold leading-tight text-white mb-1 drop-shadow-md">{book.title}</h3>
                                <p className="text-sm text-slate-300 font-medium">{book.author}</p>
                                
                                <div className="mt-4 w-full bg-white/10 h-1 rounded-full overflow-hidden">
                                    <motion.div 
                                        initial={{ width: 0 }}
                                        animate={{ width: `${book.progress}%` }}
                                        className="bg-blue-500 h-full rounded-full" 
                                    ></motion.div>
                                </div>
                            </div>

                            <div className="absolute top-4 right-4 translate-y-2 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all">
                                <button 
                                    onClick={(e) => handleDelete(e, book.id)}
                                    className="p-3 bg-red-500/20 backdrop-blur-md border border-red-500/30 rounded-full text-red-400 hover:bg-red-500 hover:text-white transition-all shadow-lg"
                                >
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        </motion.div>
                    ))}
                </AnimatePresence>
            </div>
        </motion.div>
    );
};

export default LibraryView;
