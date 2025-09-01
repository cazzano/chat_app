"use client";

import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

const Particle = ({ style, className }: { style: React.CSSProperties, className?: string }) => (
  <div className={cn("absolute rounded-full bg-primary/20", className)} style={style}></div>
);

const BackgroundParticles = ({ count = 50 }) => {
  const [particles, setParticles] = useState<React.CSSProperties[]>([]);

  useEffect(() => {
    const newParticles = Array.from({ length: count }).map(() => ({
      left: `${Math.random() * 100}vw`,
      width: `${Math.random() * 2 + 1}px`,
      height: `${Math.random() * 2 + 1}px`,
      animation: `floatUp ${Math.random() * 20 + 20}s ${Math.random() * 20}s linear infinite`,
      willChange: 'transform, opacity'
    }));
    setParticles(newParticles);
  }, [count]);

  return (
    <div className="fixed inset-0 z-[-1] pointer-events-none overflow-hidden">
      {particles.map((style, i) => (
        <Particle key={i} style={style} />
      ))}
    </div>
  );
};


const HexStream = () => {
    const [hexLines, setHexLines] = useState<string[]>([]);
    
    useEffect(() => {
        const generateHexLine = (len: number) => Array.from({ length: len }, () => (Math.random() * 16 | 0).toString(16)).join('');
        const newHexLines = Array.from({ length: 150 }).map(() => generateHexLine(Math.floor(Math.random() * 20) + 15));
        setHexLines(newHexLines);
    }, []);

    return (
        <>
            <div className="fixed top-0 left-4 w-48 h-full pointer-events-none z-[-1] overflow-hidden">
                <div className="absolute top-0 text-primary/10 font-code text-sm" style={{animation: 'matrix-scroll 180s linear infinite', willChange: 'transform'}}>
                    {hexLines.map((line, i) => <p key={i}>{line}</p>)}
                    {hexLines.map((line, i) => <p key={i + hexLines.length}>{line}</p>)}
                </div>
            </div>
            <div className="fixed top-0 right-4 w-48 h-full pointer-events-none z-[-1] overflow-hidden">
                 <div className="absolute top-0 text-primary/10 font-code text-sm" style={{animation: 'matrix-scroll-reverse 220s linear infinite', willChange: 'transform'}}>
                    {hexLines.map((line, i) => <p key={i}>{line}</p>)}
                    {hexLines.map((line, i) => <p key={i + hexLines.length}>{line}</p>)}
                </div>
            </div>
        </>
    );
};


export default function VisualEffects() {
  return (
    <div aria-hidden="true">
      <div className="fixed inset-0 z-[100] pointer-events-none scanlines" />
      <div className="fixed inset-0 z-[100] pointer-events-none noise" />
      <div className="fixed inset-0 z-[100] pointer-events-none vignette" />
      <BackgroundParticles />
      <HexStream />
    </div>
  );
}
