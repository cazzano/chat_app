"use client";

import type { Contact } from "@/lib/mock-data";
import { cn } from "@/lib/utils";
import Link from "next/link";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Code2, LogOut } from 'lucide-react';
import { CyberpunkBorder } from "@/components/cyberpunk-border";

interface ContactListProps {
  contacts: Contact[];
  selectedContactId: string;
  onContactSelect: (contact: Contact) => void;
}

export function ContactList({
  contacts,
  selectedContactId,
  onContactSelect,
}: ContactListProps) {
  return (
    <CyberpunkBorder as="aside" className="w-full max-w-xs flex-col hidden md:flex m-2">
       <div className="p-4 cyber-border-b flex items-center gap-2">
        <Code2 className="h-8 w-8 text-primary animate-pulse" />
        <div>
            <h1 className="text-2xl font-bold text-primary font-headline uppercase tracking-wider" style={{ textShadow: '0 0 8px hsl(var(--primary))' }}>NeuroLink</h1>
            <p className="text-xs text-muted-foreground font-code">// ENCRYPTED MESSAGING</p>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto">
        <nav className="p-2">
          <ul>
            {contacts.map((contact) => (
              <li key={contact.id}>
                <button
                  onClick={() => onContactSelect(contact)}
                  className={cn(
                    "w-full text-left p-2 flex items-center gap-4 transition-colors duration-200 relative hover:bg-primary/10",
                    selectedContactId === contact.id
                      ? "bg-primary/20"
                      : "bg-transparent"
                  )}
                  style={{
                    clipPath: 'polygon(0 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, 8px 100%, 0 calc(100% - 8px))'
                  }}
                >
                  {selectedContactId === contact.id && <div className="absolute left-0 top-0 h-full w-1 bg-secondary animate-pulse" />}
                  <div className="relative">
                    <Avatar className="h-12 w-12 border-2 border-primary/50">
                      <AvatarImage src={contact.avatar} alt={contact.name} data-ai-hint={contact.dataAiHint} />
                      <AvatarFallback>{contact.name.charAt(0)}</AvatarFallback>
                    </Avatar>
                    {contact.status === 'online' && (
                        <span className="absolute bottom-0 right-0 block h-3 w-3 rounded-full bg-primary ring-2 ring-card" />
                    )}
                  </div>
                  <div className="flex-1 overflow-hidden">
                    <p className="font-semibold truncate font-headline text-primary/90 uppercase">{contact.name}</p>
                    <p className="text-sm text-muted-foreground truncate font-code">{contact.lastMessagePreview}</p>
                  </div>
                  <span className="text-xs text-muted-foreground font-code">{contact.lastMessageTimestamp}</span>
                </button>
              </li>
            ))}
          </ul>
        </nav>
      </div>
       <div className="mt-auto p-2 cyber-border-t">
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
                <Button asChild variant="ghost" className="w-full justify-start text-red-400 hover:bg-red-500/20 hover:text-red-300">
                    <Link href="/login">
                        <LogOut className="h-5 w-5 mr-3" />
                        <span className="font-headline uppercase">Disconnect</span>
                    </Link>
                </Button>
            </TooltipTrigger>
            <TooltipContent side="right" align="center">
              <p>Return to Login Terminal</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>
    </CyberpunkBorder>
  );
}
