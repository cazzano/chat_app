"use client";

import * as React from "react";
import type { Contact, Message } from "@/lib/mock-data";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import { MessageBubble } from "@/components/message-bubble";
import { Send, Rss, ShieldCheck } from "lucide-react";
import { CyberpunkBorder } from "@/components/cyberpunk-border";
import { LiveTypingDisplay } from "@/components/live-typing-display";

interface ChatAreaProps {
  contact: Contact;
  messages: Message[];
  onSendMessage: (message: string) => void;
}

export function ChatArea({ contact, messages, onSendMessage }: ChatAreaProps) {
  const [newMessage, setNewMessage] = React.useState("");
  const scrollAreaRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    if (scrollAreaRef.current) {
        const viewport = scrollAreaRef.current.querySelector('div[data-radix-scroll-area-viewport]');
        if (viewport) {
            viewport.scrollTop = viewport.scrollHeight;
        }
    }
  }, [messages]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim()) return;
    onSendMessage(newMessage);
    setNewMessage("");
  };

  return (
    <CyberpunkBorder className="flex flex-1 flex-col m-2" style={{ clipPath: "polygon(0 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, 8px 100%, 0 calc(100% - 8px))"}}>
      <header className="flex items-center gap-4 p-4 cyber-border-b">
        <Avatar className="h-12 w-12 border-2 border-primary">
          <AvatarImage src={contact.avatar} alt={contact.name} data-ai-hint={contact.dataAiHint} />
          <AvatarFallback>{contact.name.charAt(0)}</AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <h2 className="text-xl font-bold font-headline uppercase text-primary tracking-widest" style={{ textShadow: '0 0 5px hsl(var(--primary))' }}>{contact.name}</h2>
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            {contact.status === "online" ? (
              <>
                <Rss className="h-4 w-4 text-primary animate-pulse" />
                Online
              </>
            ) : (
              "Offline"
            )}
          </div>
        </div>
        <div className="flex items-center gap-2 text-primary animate-pulse">
          <ShieldCheck className="h-5 w-5" />
          <span className="text-sm font-medium uppercase">Quantum-Encrypted</span>
        </div>
      </header>
      
      <ScrollArea className="flex-1" ref={scrollAreaRef}>
        <div className="p-6 space-y-6">
          {messages.map((message) => (
            <MessageBubble key={message.id} message={message} contactAvatar={contact.avatar} contactAiHint={contact.dataAiHint} />
          ))}
        </div>
      </ScrollArea>

      <footer className="p-4 bg-card/80 mt-auto space-y-2">
        <LiveTypingDisplay text={newMessage} />
        <form onSubmit={handleSubmit} className="flex items-center gap-4">
          <Input
            type="text"
            placeholder="> INITIATE_COMMUNICATION..."
            className="flex-1 bg-input text-foreground caret-primary selection:bg-primary/20 selection:text-white font-code border-primary/50 focus:ring-primary uppercase"
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            aria-label="Chat message input"
            autoComplete="off"
          />
          <Button type="submit" size="icon" aria-label="Send message" variant="outline" className="border-primary/50 text-primary hover:bg-primary hover:text-primary-foreground">
            <Send className="h-5 w-5" />
          </Button>
        </form>
      </footer>
    </CyberpunkBorder>
  );
}
