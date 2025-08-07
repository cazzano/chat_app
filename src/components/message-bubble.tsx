"use client"

import type { Message } from "@/lib/mock-data";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

interface MessageBubbleProps {
  message: Message;
  contactAvatar: string;
  contactAiHint: string;
}

export function MessageBubble({ message, contactAvatar, contactAiHint }: MessageBubbleProps) {
  const isMe = message.sender === "me";

  return (
    <div
      className={cn(
        "flex items-end gap-3 max-w-[75%]",
        isMe ? "ml-auto flex-row-reverse" : "mr-auto",
        !message.isNew && "animate-in fade-in slide-in-from-bottom-2 duration-300"
      )}
    >
      <Avatar className={cn("h-8 w-8 border border-primary/50", isMe && "hidden")}>
        <AvatarImage src={contactAvatar} alt="Contact Avatar" data-ai-hint={contactAiHint} />
        <AvatarFallback>C</AvatarFallback>
      </Avatar>
      <div
        className={cn(
          "p-3 w-fit relative",
          isMe
            ? "bg-primary text-primary-foreground"
            : "bg-secondary text-secondary-foreground",
          "cyber-border",
           message.isNew ? "animate-glitch" : ""
        )}
        style={{
            clipPath: isMe
              ? "polygon(0 8px, 8px 0, 100% 0, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0 100%)"
              : "polygon(0 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, 8px 100%, 0 calc(100% - 8px))",
        }}
        data-text={message.text}
      >
        <p className={cn("text-sm leading-relaxed font-code uppercase")} style={{ textShadow: '0 0 2px currentColor, 0 0 5px currentColor' }}>{message.text}</p>
      </div>
      <span className="text-xs text-muted-foreground/60 pb-1 font-code">
        {message.timestamp}
      </span>
    </div>
  );
}
