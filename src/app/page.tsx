import { generateAccessEvents } from '@/ai/flows/generate-access-events';
import AidenAppClient from '@/components/aiden-app-client';

export const dynamic = 'force-dynamic';

const MOCK_EVENTS = [
    "Initializing...",
    "Connecting to secure channel...",
    "Authenticating...",
    "Loading modules...",
    "Access granted."
];

export default async function Home() {
  let events: string[];

  if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'YOUR_API_KEY_HERE') {
    try {
      const result = await generateAccessEvents({ numberOfEvents: 5 });
      events = result.events;
    } catch (error) {
      console.error("Error generating access events, using mock data:", error);
      events = MOCK_EVENTS;
    }
  } else {
    console.log("GEMINI_API_KEY not found, using mock data.");
    events = MOCK_EVENTS;
  }

  return <AidenAppClient accessEvents={events} />;
}
