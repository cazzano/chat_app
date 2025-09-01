"use client";

import { useState, useEffect, type FC } from 'react';
import { Smartphone, Terminal, Cpu, ShieldCheck, Wifi, Server } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { WindowsIcon } from '@/components/icons';
import ScrollFadeIn from '@/components/scroll-fade-in';
import Typewriter from '@/components/typewriter';
import { cn } from '@/lib/utils';
import Image from 'next/image';

const bootMessages = [
  "//: Initializing CTOS v2.0...",
  "//: Connecting to DedSec uplink...",
  "//: Bypassing enterprise firewall...",
  "//: Establishing secure shell...",
  "//: Accessing mainframe...",
  "//: Welcome, Operative.",
];

const BootLoader: FC<{ onFinished: () => void }> = ({ onFinished }) => {
  const [messageIndex, setMessageIndex] = useState(0);

  useEffect(() => {
    if (messageIndex < bootMessages.length - 1) {
      const timer = setTimeout(() => {
        setMessageIndex(prev => prev + 1);
      }, 700);
      return () => clearTimeout(timer);
    } else {
      const finishTimer = setTimeout(onFinished, 1000);
      return () => clearTimeout(finishTimer);
    }
  }, [messageIndex, onFinished]);

  return (
    <div className="fixed inset-0 bg-background flex items-center justify-center z-[200]">
      <div className="font-code text-primary w-full max-w-md text-center p-4">
        {bootMessages.slice(0, messageIndex + 1).map((msg, i) => (
          <div key={i} className="text-lg text-left">
            {i === messageIndex ? <Typewriter text={msg} speed={30} /> : msg}
          </div>
        ))}
      </div>
    </div>
  );
};

const Header = () => (
  <header className="fixed top-0 left-0 right-0 z-50 p-4 bg-background/50 backdrop-blur-sm">
    <div className="container mx-auto flex justify-between items-center">
      <h1 className="font-headline text-xl md:text-2xl text-primary glitch-hover group" data-text="Cazzano's Chat App Store">
        Cazzano's Chat App Store
      </h1>
      <div className="text-primary font-code text-xs md:text-sm">
        <span className="text-muted-foreground">// status:</span> online
      </div>
    </div>
  </header>
);

const HeroSection: FC<{ accessEvents: string[] }> = ({ accessEvents }) => (
  <section className="min-h-screen flex items-center justify-center pt-20 pb-10">
    <div className="text-center relative">
      <ScrollFadeIn>
        <Image src="https://picsum.photos/150/150" alt="App Logo" width={150} height={150} data-ai-hint="hacker logo" className="mx-auto mb-8 rounded-full border-2 border-primary shadow-lg shadow-primary/20 opacity-70" />
      </ScrollFadeIn>
      <ScrollFadeIn delay={200}>
        <h2 className="font-headline text-5xl md:text-7xl lg:text-8xl text-primary uppercase" style={{ textShadow: '0 0 10px hsl(var(--primary)), 0 0 20px hsl(var(--primary))' }}>
          <Typewriter text="Retribution OS" speed={100} />
        </h2>
      </ScrollFadeIn>
      <ScrollFadeIn delay={400}>
        <p className="mt-4 text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto">
          The premier open-source chat client for secure, decentralized communication. Your privacy is not a feature; it's the foundation.
        </p>
      </ScrollFadeIn>
      <ScrollFadeIn delay={600} className="mt-8 font-code text-left max-w-md mx-auto bg-card/50 p-4 rounded-md border border-primary/20 text-sm">
        {accessEvents.map((event, i) => (
          <p key={i} className="text-secondary">
            <Typewriter text={`> ${event}`} speed={20} startDelay={1000 + i * 200} />
          </p>
        ))}
        <p className="text-green-400">
            <Typewriter text="> ACCESS GRANTED" speed={20} startDelay={1000 + accessEvents.length * 200} />
        </p>
      </ScrollFadeIn>
    </div>
  </section>
);

const features = [
  { icon: ShieldCheck, title: "End-to-End Encryption", description: "Military-grade AES-256 encryption ensures your conversations are for your eyes only." },
  { icon: Server, title: "Decentralized Network", description: "No central servers. No data collection. Your communication is peer-to-peer." },
  { icon: Wifi, title: "Offline Messaging", description: "Messages are queued and delivered once you and your contact are both online. No data loss." },
  { icon: Terminal, title: "Open Source Core", description: "Fully transparent and auditable codebase. Trust through verification." },
];

const FeaturesSection = () => (
    <section id="features" className="py-20">
        <ScrollFadeIn>
             <h3 className="text-center font-headline text-4xl md:text-5xl text-primary mb-12 uppercase">// Features</h3>
        </ScrollFadeIn>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, i) => (
                <ScrollFadeIn key={feature.title} delay={i * 150}>
                    <Card className="bg-card/70 border-primary/20 h-full hover:border-primary/50 transition-all duration-300 hover:shadow-lg hover:shadow-primary/10">
                        <CardHeader className="items-center text-center">
                            <feature.icon className="w-12 h-12 text-primary mb-4" />
                            <CardTitle className="font-headline text-2xl text-secondary">{feature.title}</CardTitle>
                        </CardHeader>
                        <CardContent className="text-center text-muted-foreground">
                            {feature.description}
                        </CardContent>
                    </Card>
                </ScrollFadeIn>
            ))}
        </div>
    </section>
);


type OS = 'windows' | 'linux' | 'android' | 'other';
const downloads = [
    { os: 'windows' as OS, name: "Windows x64", icon: WindowsIcon, url: "https://1024terabox.com/s/1tzcvE4DSWK23GYNFjf8ZBw" },
    { os: 'android' as OS, name: "Android (All)", icon: Smartphone, url: "https://1024terabox.com/s/1iG8SDaU3GqPB5X8y36qqQQ" },
    { os: 'linux' as OS, name: "Linux (Arch)", icon: Terminal, url: "https://1024terabox.com/s/1IwYpnhHO7CotXUGaRAaw2w" }
];

const DownloadSection = () => {
    const [detectedOS, setDetectedOS] = useState<OS>('other');

    useEffect(() => {
        const ua = navigator.userAgent;
        if (/android/i.test(ua)) setDetectedOS('android');
        else if (/linux/i.test(ua) && !/android/i.test(ua)) setDetectedOS('linux');
        else if (/windows/i.test(ua)) setDetectedOS('windows');
    }, []);

    return (
         <section id="download" className="py-20">
            <ScrollFadeIn>
                <h3 className="text-center font-headline text-4xl md:text-5xl text-accent mb-4 uppercase">// Download Client</h3>
                <p className="text-center text-muted-foreground mb-12 max-w-xl mx-auto">Select your operating system to begin infiltration. Your recommended system has been highlighted.</p>
            </ScrollFadeIn>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {downloads.map((dl, i) => {
                    const isRecommended = dl.os === detectedOS;
                    return (
                        <ScrollFadeIn key={dl.os} delay={i * 150}>
                             <Card className={cn(
                                "bg-card/70 border-2 text-center p-8 flex flex-col items-center justify-center transition-all duration-300 group",
                                isRecommended ? "border-accent/80 shadow-lg shadow-accent/20" : "border-primary/20 hover:border-primary/50"
                             )}>
                                <dl.icon className="w-16 h-16 mb-4 text-primary group-hover:text-secondary transition-colors" />
                                <h4 className="font-headline text-2xl text-secondary mb-2">{dl.name}</h4>
                                <Button asChild className={cn("mt-4 w-full glitch-button", isRecommended && "bg-accent text-accent-foreground hover:bg-accent/90 pulse-glow")} data-text="Download">
                                    <a href={dl.url} target="_blank" rel="noopener noreferrer">Download</a>
                                </Button>
                                {isRecommended && <p className="text-accent text-xs mt-2 font-code">// Recommended</p>}
                            </Card>
                        </ScrollFadeIn>
                    )
                })}
            </div>
        </section>
    );
}

const SystemRequirementsSection = () => (
    <section id="requirements" className="py-20">
        <ScrollFadeIn>
            <h3 className="text-center font-headline text-4xl md:text-5xl text-primary mb-12 uppercase">// System Analysis</h3>
        </ScrollFadeIn>
        <ScrollFadeIn delay={200}>
        <Card className="bg-card/70 border-primary/20 font-code text-muted-foreground p-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-4">
                <div><span className="text-primary mr-2">CPU:</span> <span className="text-white">Dual Core 2.0GHz+</span></div>
                <div><span className="text-primary mr-2">RAM:</span> <span className="text-white">4GB Minimum</span></div>
                <div><span className="text-primary mr-2">OS:</span> <span className="text-white">Windows 10+, Linux (Kernel 5+), Android 8+</span></div>
                <div><span className="text-primary mr-2">DISK:</span> <span className="text-white">250MB Free Space</span></div>
                <div><span className="text-primary mr-2">NETWORK:</span> <span className="text-white">Broadband Internet Connection</span></div>
                <div><span className="text-primary mr-2">PERMISSIONS:</span> <span className="text-green-400">ROOT ACCESS NOT REQUIRED</span></div>
            </div>
        </Card>
        </ScrollFadeIn>
    </section>
);

const ContactSection = () => (
    <section id="contact" className="py-20">
        <ScrollFadeIn>
            <h3 className="text-center font-headline text-4xl md:text-5xl text-accent mb-12 uppercase">// Secure Comms</h3>
        </ScrollFadeIn>
        <ScrollFadeIn delay={200}>
            <Card className="bg-card/70 border-primary/20 font-code text-muted-foreground p-8 text-center">
                <p className="text-lg">For support or inquiries, establish a secure connection:</p>
                <a href="mailto:support@retribution.os" className="text-accent text-2xl glitch-button mt-4 inline-block" data-text="support@retribution.os">
                    support@retribution.os
                </a>
                <p className="mt-6 text-primary/50 text-sm">// All communications are monitored and encrypted.</p>
            </Card>
        </ScrollFadeIn>
    </section>
);

const CurrentYear = () => {
    const [year, setYear] = useState<number | null>(null);
    useEffect(() => {
        setYear(new Date().getFullYear());
    }, []);
    return <>{year}</>;
}


const Footer = () => (
    <footer className="py-8 border-t border-primary/20 font-code text-sm">
        <div className="container mx-auto text-center text-muted-foreground">
            <p>Retribution OS &copy; <CurrentYear />. All rights reserved.</p>
            <p className="text-primary/50 mt-2">// Disconnecting from mainframe...</p>
        </div>
    </footer>
);


type AidenAppClientProps = {
  accessEvents: string[];
};

export default function AidenAppClient({ accessEvents }: AidenAppClientProps) {
  const [loading, setLoading] = useState(true);

  return (
    <>
      {loading && <BootLoader onFinished={() => setLoading(false)} />}
      <div className={cn("transition-opacity duration-1000", loading ? 'opacity-0' : 'opacity-100')}>
        <Header />
        <main className="container mx-auto px-4">
            <HeroSection accessEvents={accessEvents} />
            <FeaturesSection />
            <DownloadSection />
            <SystemRequirementsSection />
            <ContactSection />
        </main>
        <Footer />
      </div>
    </>
  );
}
