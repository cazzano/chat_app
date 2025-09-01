"use client";
import { cn } from '@/lib/utils';
import { useState, useEffect, useRef } from 'react';

type TypewriterProps = {
  text: string;
  speed?: number;
  onComplete?: () => void;
  className?: string;
  startDelay?: number;
};

export default function Typewriter({ text, speed = 50, onComplete, className, startDelay = 0 }: TypewriterProps) {
  const [displayedText, setDisplayedText] = useState('');
  const [isStarted, setIsStarted] = useState(false);
  const index = useRef(0);

  useEffect(() => {
    const startTimeout = setTimeout(() => {
        setIsStarted(true);
    }, startDelay);

    return () => clearTimeout(startTimeout);
  }, [startDelay]);

  useEffect(() => {
    if (isStarted && index.current < text.length) {
      const timeoutId = setTimeout(() => {
        setDisplayedText((prev) => prev + text.charAt(index.current));
        index.current += 1;
      }, speed);
      return () => clearTimeout(timeoutId);
    } else if (index.current >= text.length && onComplete) {
      onComplete();
    }
  }, [displayedText, isStarted, text, speed, onComplete]);

  return <span className={className}>{displayedText}<span className="blinking-cursor">_</span></span>;
}
