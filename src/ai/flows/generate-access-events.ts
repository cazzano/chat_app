'use server';

/**
 * @fileOverview An AI agent that generates realistic access events for the application.
 *
 * - generateAccessEvents - A function that generates access events.
 * - GenerateAccessEventsInput - The input type for the generateAccessEvents function.
 * - GenerateAccessEventsOutput - The return type for the generateAccessEvents function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateAccessEventsInputSchema = z.object({
  numberOfEvents: z
    .number()
    .describe('The number of access events to generate.')
    .default(3),
});
export type GenerateAccessEventsInput = z.infer<typeof GenerateAccessEventsInputSchema>;

const GenerateAccessEventsOutputSchema = z.object({
  events: z.array(
    z.string().describe('A realistic access event message.')
  ).describe('An array of realistic access event messages.'),
});
export type GenerateAccessEventsOutput = z.infer<typeof GenerateAccessEventsOutputSchema>;

export async function generateAccessEvents(
  input: GenerateAccessEventsInput
): Promise<GenerateAccessEventsOutput> {
  return generateAccessEventsFlow(input);
}

const prompt = ai.definePrompt({
  name: 'generateAccessEventsPrompt',
  input: {schema: GenerateAccessEventsInputSchema},
  output: {schema: GenerateAccessEventsOutputSchema},
  prompt: `You are a security system AI generating realistic access events for a system loading sequence.

  Generate {{numberOfEvents}} access event messages that mimic real system access loading indicators and confirmations.
  Make sure each event is concise and realistic.
  Example events:
  - \"Connecting to the mainframe...\"
  - \"Access Granted: User authenticated.\"
  - \"Loading core modules...\"
  - \"Initializing security protocols...\"
  - \"Database connection established.\"
  - \"Firewall online.\"
  - \"System diagnostics complete.\"
  - \"Awaiting user input...\"
  - \"Executing system startup scripts...\"
  - \"Verifying system integrity...\"
  - \"Establishing secure connection...\"
  - \"Loading system configuration...\"
  - \"Finalizing system initialization...\"
  `,
});

const generateAccessEventsFlow = ai.defineFlow(
  {
    name: 'generateAccessEventsFlow',
    inputSchema: GenerateAccessEventsInputSchema,
    outputSchema: GenerateAccessEventsOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);

