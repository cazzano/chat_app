"use client";

import * as React from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { LoginForm, SignUpForm, MatrixRain } from './components';
import { Code2, Home } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function LoginPage() {
  const [currentTime, setCurrentTime] = React.useState('');

  React.useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      setCurrentTime(now.toLocaleTimeString('en-US', { hour12: false }));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="flex items-center justify-center min-h-screen bg-black text-white font-code relative overflow-hidden">
      <MatrixRain />
      <div className="absolute inset-0 bg-black/60" />
      
      <div className="relative z-10 w-full max-w-4xl p-4 md:p-8 border-2 border-primary/50 bg-black/70 backdrop-blur-sm"
        style={{
          boxShadow: '0 0 25px hsl(var(--primary)), inset 0 0 15px hsl(var(--primary) / 0.5)',
          clipPath: 'polygon(0% 20px, 20px 0%, calc(100% - 20px) 0%, 100% 20px, 100% calc(100% - 20px), calc(100% - 20px) 100%, 20px 100%, 0% calc(100% - 20px))'
        }}
      >
        <Link href="/" passHref>
          <Button variant="ghost" size="icon" className="absolute top-2 left-4 text-primary/70 hover:bg-primary/20 hover:text-primary">
            <Home className="h-6 w-6" />
          </Button>
        </Link>
        <div className="absolute top-2 right-4 text-xs text-primary/70">
          <p>v2.077.45</p>
          <p>{currentTime}</p>
        </div>
        <div className="absolute bottom-2 left-4 text-xs text-primary/70">
          <p>// UNAUTHORIZED ACCESS PROHIBITED - ARASAKA SECURITY ACTIVE</p>
        </div>

        <div className="text-center mb-8">
            <div className="inline-block">
                <Code2 className="h-16 w-16 text-primary" style={{filter: 'drop-shadow(0 0 10px hsl(var(--primary)))'}}/>
            </div>
          <h1 className="text-3xl md:text-5xl font-headline uppercase text-primary" style={{textShadow: '0 0 15px hsl(var(--primary))'}}>
            Netrunner Terminal
          </h1>
          <p className="text-primary/80">Night City Network Access</p>
        </div>

        <Tabs defaultValue="login" className="w-full">
          <TabsList className="grid w-full grid-cols-2 bg-transparent border-2 border-primary/30 p-1">
            <TabsTrigger value="login" className="data-[state=active]:bg-primary/30 data-[state=active]:text-primary data-[state=active]:shadow-none font-headline uppercase">
              Login_Mode
            </TabsTrigger>
            <TabsTrigger value="signup" className="data-[state=active]:bg-primary/30 data-[state=active]:text-primary data-[state=active]:shadow-none font-headline uppercase">
              Register_Mode
            </TabsTrigger>
          </TabsList>
          <TabsContent value="login">
            <LoginForm />
          </TabsContent>
          <TabsContent value="signup">
            <SignUpForm />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
