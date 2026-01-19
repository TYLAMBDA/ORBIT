import { LucideIcon } from 'lucide-react';

export type DockPosition = 'center' | 'left' | 'right' | 'top' | 'bottom';
export type Language = 'en' | 'zh';

export interface MenuItem {
  id: string;
  label: string;
  icon: LucideIcon;
  targetDock: DockPosition; // Where the sphere goes when this is active
  color: string;
  special?: boolean; // For the offline button
}

export interface Book {
  id: string;
  title: string;
  author: string;
  coverColor: string;
  progress: number;
}

export interface User {
  username: string;
  email: string;
  avatar: string; // Tailwind color class string
  stats: {
    totalReadingHours: number;
    booksRead: string[];
    booksPublished: string[];
  };
}
