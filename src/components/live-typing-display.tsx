"use client";

import * as React from "react";
import { cn } from "@/lib/utils";

interface LiveTypingDisplayProps {
  text: string;
}

interface AnimatedWord {
  id: string;
  word: string;
  justAdded: boolean;
}

export function LiveTypingDisplay({ text }: LiveTypingDisplayProps) {
  const [animatedWords, setAnimatedWords] = React.useState<AnimatedWord[]>([]);
  const [currentWord, setCurrentWord] = React.useState("");
  const displayRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    const parts = text.split(/(\s+)/); // Split by space, keeping the delimiter
    const words = parts.filter(part => part.trim().length > 0);
    const spaces = parts.filter(part => part.trim().length === 0);

    const lastFullWordIndex = text.endsWith(" ") ? words.length : words.length - 1;
    
    const newAnimatedWords = words.slice(0, lastFullWordIndex).map((word, index) => ({
      id: `${word}-${index}`,
      word,
      justAdded: false,
    }));

    const lastCompletedWord = words[lastFullWordIndex - 1];
    const prevLastCompletedWord = animatedWords[animatedWords.length - 1]?.word;

    if (lastCompletedWord && lastCompletedWord !== prevLastCompletedWord) {
       const lastWord = newAnimatedWords[newAnimatedWords.length -1];
       if(lastWord) {
         lastWord.justAdded = true;
       }
    }
    
    setAnimatedWords(newAnimatedWords);
    setCurrentWord(words[lastFullWordIndex] || "");

  }, [text]);

  React.useEffect(() => {
    if (displayRef.current) {
        const lastSpan = displayRef.current.querySelector('span:last-of-type');
        if (lastSpan) {
            lastSpan.scrollIntoView({ behavior: 'smooth', block: 'end' });
        }
    }
  }, [animatedWords, currentWord]);


  return (
    <div 
      ref={displayRef}
      className="w-full min-h-[2.5rem] p-2 bg-input/70 rounded-md border border-primary/30 text-base font-code uppercase"
      aria-hidden="true"
    >
      {animatedWords.map((item, index) => (
        <React.Fragment key={item.id}>
          <span className={cn("live-word", item.justAdded && "word-burst")} style={{ animationDelay: `${(index % 10) * 0.1}s` }}>
            {item.word.split("").map((char, i) => (
              <span key={i} className="live-char" style={{ animationDelay: `${i * 0.05}s`}}>{char}</span>
            ))}
          </span>
          {' '}
        </React.Fragment>
      ))}
       {currentWord && <span>{currentWord}</span>}
      <span className="live-typing-cursor" />
    </div>
  );
}
