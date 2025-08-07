"use client";

import * as React from "react";
import {
  contactData,
  messageData,
  type Contact,
  type Message,
} from "@/lib/mock-data";
import { ContactList } from "@/components/contact-list";
import { ChatArea } from "@/components/chat-area";

export default function Home() {
  const [contacts] = React.useState<Contact[]>(contactData);
  const [messages, setMessages] = React.useState<Record<string, Message[]>>(messageData);
  const [selectedContact, setSelectedContact] = React.useState<Contact>(
    contacts[0]
  );

  const handleSendMessage = (newMessageText: string) => {
    if (!newMessageText.trim()) return;

    const newMessage: Message = {
      id: `msg-${Date.now()}`,
      text: newMessageText,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      sender: "me",
      isNew: true,
    };

    setMessages((prevMessages) => {
      const newContactMessages = [...(prevMessages[selectedContact.id] || []), newMessage];
      // Mark previous messages as not new
      const oldMessages = prevMessages[selectedContact.id]?.map(m => ({...m, isNew: false })) || [];

      return {
        ...prevMessages,
        [selectedContact.id]: [...oldMessages.slice(-10), newMessage], // Keep history but mark as old
      };
    });
  };

  return (
    <main className="flex h-screen w-full bg-transparent">
      <div className="flex flex-1">
        <ChatArea
          contact={selectedContact}
          messages={messages[selectedContact.id] || []}
          onSendMessage={handleSendMessage}
        />
      </div>
      <ContactList
        contacts={contacts}
        selectedContactId={selectedContact.id}
        onContactSelect={setSelectedContact}
      />
    </main>
  );
}
