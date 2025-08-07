export type Contact = {
  id: string;
  name: string;
  avatar: string;
  status: "online" | "offline";
  lastMessagePreview: string;
  lastMessageTimestamp: string;
  dataAiHint: string;
};

export type Message = {
  id: string;
  text: string;
  timestamp: string;
  sender: "me" | string; // 'me' or contact.id
  isNew?: boolean;
};

export const contactData: Contact[] = [
  {
    id: "contact-1",
    name: "Aria",
    avatar: "https://placehold.co/40x40/00FFFF/223344.png",
    status: "online",
    lastMessagePreview: "The quantum flux seems stable.",
    lastMessageTimestamp: "5m ago",
    dataAiHint: "woman portrait"
  },
  {
    id: "contact-2",
    name: "Jaxon",
    avatar: "https://placehold.co/40x40/800080/FFFFFF.png",
    status: "online",
    lastMessagePreview: "I've recalibrated the servers.",
    lastMessageTimestamp: "1h ago",
    dataAiHint: "man portrait"
  },
  {
    id: "contact-3",
    name: "Cygnus-X1",
    avatar: "https://placehold.co/40x40/FFFFFF/223344.png",
    status: "offline",
    lastMessagePreview: "...",
    lastMessageTimestamp: "3d ago",
    dataAiHint: "robot face"
  },
  {
    id: "contact-4",
    name: "Dr. Evelyn Reed",
    avatar: "https://placehold.co/40x40/00FFFF/223344.png",
    status: "offline",
    lastMessagePreview: "The data is fascinating.",
    lastMessageTimestamp: "1w ago",
    dataAiHint: "woman scientist"
  },
  {
    id: "contact-5",
    name: "Kaelen",
    avatar: "https://placehold.co/40x40/800080/FFFFFF.png",
    status: "online",
    lastMessagePreview: "The nebula is beautiful tonight.",
    lastMessageTimestamp: "2h ago",
    dataAiHint: "man smiling"
  },
  {
    id: "contact-6",
    name: "Lyra",
    avatar: "https://placehold.co/40x40/00FFFF/223344.png",
    status: "offline",
    lastMessagePreview: "See you at the usual spot.",
    lastMessageTimestamp: "yesterday",
    dataAiHint: "woman serious"
  },
  {
    id: "contact-7",
    name: "Orion",
    avatar: "https://placehold.co/40x40/FFFFFF/223344.png",
    status: "online",
    lastMessagePreview: "Just deployed the new code.",
    lastMessageTimestamp: "30m ago",
    dataAiHint: "man space"
  }
];

export const messageData: Record<string, Message[]> = {
  "contact-1": [
    {
      id: "msg-1-1",
      sender: "contact-1",
      text: "Did you receive the encrypted data stream?",
      timestamp: "10:00 AM",
    },
    {
      id: "msg-1-2",
      sender: "me",
      text: "Affirmative. The packet is secure. Analyzing now.",
      timestamp: "10:01 AM",
    },
    {
      id: "msg-1-3",
      sender: "contact-1",
      text: "Excellent. The quantum flux seems stable on my end. No anomalies detected.",
      timestamp: "10:02 AM",
    },
  ],
  "contact-2": [
    {
      id: "msg-2-1",
      sender: "contact-2",
      text: "Patch is complete. I've recalibrated the servers.",
      timestamp: "9:30 AM",
    },
    {
      id: "msg-2-2",
      sender: "me",
      text: "Acknowledged. I'll run diagnostics.",
      timestamp: "9:31 AM",
    },
  ],
  "contact-3": [],
  "contact-4": [
    {
      id: "msg-4-1",
      sender: "contact-4",
      text: "The data from the probe is fascinating. It's unlike anything we've seen.",
      timestamp: "Yesterday",
    },
  ],
  "contact-5": [
    {
      id: "msg-5-1",
      sender: "contact-5",
      text: "The nebula is beautiful tonight.",
      timestamp: "8:00 PM"
    },
    {
      id: "msg-5-2",
      sender: "me",
      text: "Agreed. The view from this sector is incredible.",
      timestamp: "8:01 PM"
    }
  ],
  "contact-6": [
    {
      id: "msg-6-1",
      sender: "contact-6",
      text: "See you at the usual spot.",
      timestamp: "Yesterday"
    },
  ],
  "contact-7": [
    {
      id: "msg-7-1",
      sender: "contact-7",
      text: "Just deployed the new code.",
      timestamp: "11:00 AM"
    },
    {
      id: "msg-7-2",
      sender: "me",
      text: "Running tests now. Looks good so far.",
      timestamp: "11:02 AM"
    }
  ],
};
