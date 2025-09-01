"use client";
import { useRef, useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

export default function ScrollFadeIn({ children, className, delay = 0, threshold = 0.1 }: { children: React.ReactNode, className?: string, delay?: number, threshold?: number }) {
  const [isVisible, setIsVisible] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            setIsVisible(true);
          }, delay)
          if (ref.current) {
            observer.unobserve(ref.current);
          }
        }
      },
      { threshold }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => {
      if (ref.current) {
        observer.unobserve(ref.current);
      }
    };
  }, [delay, threshold]);

  return (
    <div
      ref={ref}
      className={cn('transition-all duration-1000 transform opacity-0 translate-y-8', isVisible && 'opacity-100 translate-y-0', className)}
      style={{ willChange: 'transform, opacity' }}
    >
      {children}
    </div>
  );
}
