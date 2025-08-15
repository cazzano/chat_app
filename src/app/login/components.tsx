"use client";

import * as React from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Check, Copy, Eye, EyeOff } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Progress } from "@/components/ui/progress";
import QRCode from 'qrcode';
import * as OTPAuth from 'otpauth';
import { useToast } from "@/hooks/use-toast";


export function LoginForm() {
  const [isResetOpen, setIsResetOpen] = React.useState(false);

  return (
    <>
      <div className="p-4 md:p-6 border-t-2 border-primary/30 mt-2">
        <form className="space-y-6">
          <div className="grid w-full items-center gap-2.5">
            <Label htmlFor="netrunnerId" className="terminal-label">
              &gt; NETRUNNER_ID:
            </Label>
            <Input type="text" id="netrunnerId" placeholder="[________________]" className="terminal-input" />
          </div>
          <div className="grid w-full items-center gap-2.5">
            <Label htmlFor="accessCode" className="terminal-label">
              &gt; ACCESS_CODE:
            </Label>
            <Input type="password" id="accessCode" placeholder="[****************]" className="terminal-input" />
          </div>
          <div className="flex items-center justify-between flex-wrap gap-4">
              <div className="flex items-center space-x-2 terminal-checkbox">
                  <Checkbox id="save-credentials" />
                  <label
                      htmlFor="save-credentials"
                      className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                  >
                      SAVE_CREDENTIALS
                  </label>
              </div>
              <button type="button" onClick={() => setIsResetOpen(true)} className="glitch-link">RESET_ACCESS_CODES</button>
          </div>
          <Button type="submit" className="w-full terminal-button text-lg py-6">
            JACK IN
          </Button>
        </form>
      </div>
      <ResetAccessCodesFlow isOpen={isResetOpen} onOpenChange={setIsResetOpen} />
    </>
  );
}

export function SignUpForm() {
    const [isTotpOpen, setIsTotpOpen] = React.useState(false);
    const [formData, setFormData] = React.useState({ username: '', password: '' });

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        const target = e.target as typeof e.target & {
            newNetrunnerId: { value: string };
            newAccessCode: { value: string };
        };
        setFormData({
            username: target.newNetrunnerId.value,
            password: target.newAccessCode.value,
        });
        setIsTotpOpen(true);
    }
  
    return (
      <>
        <div className="p-4 md:p-6 border-t-2 border-primary/30 mt-2">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="grid w-full items-center gap-2.5">
              <Label htmlFor="newNetrunnerId" className="terminal-label">
                &gt; NEW_NETRUNNER_ID:
              </Label>
              <Input type="text" id="newNetrunnerId" name="newNetrunnerId" placeholder="[________________]" className="terminal-input" required/>
            </div>
            <div className="grid w-full items-center gap-2.5">
              <Label htmlFor="newAccessCode" className="terminal-label">
                &gt; ACCESS_CODE:
              </Label>
              <Input type="password" id="newAccessCode" name="newAccessCode" placeholder="[****************]" className="terminal-input" required />
            </div>
            <div className="grid w-full items-center gap-2.5">
              <Label htmlFor="confirmAccessCode" className="terminal-label">
                &gt; CONFIRM_CODE:
              </Label>
              <Input type="password" id="confirmAccessCode" placeholder="[****************]" className="terminal-input" required />
            </div>
            <div className="flex items-center space-x-2 terminal-checkbox">
                <Checkbox id="accept-protocols" required />
                <label
                    htmlFor="accept-protocols"
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >
                    ACCEPT NIGHT CITY NETWORK PROTOCOLS
                </label>
            </div>
            <Button type="submit" className="w-full terminal-button text-lg py-6">
              CREATE_NETRUNNER_PROFILE
            </Button>
          </form>
        </div>
        <TotpSetupPopup 
            isOpen={isTotpOpen} 
            onOpenChange={setIsTotpOpen} 
            username={formData.username}
            password={formData.password}
        />
      </>
    );
}

const generateRandomSecret = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    let secret = '';
    for (let i = 0; i < 32; i++) {
      secret += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return secret;
};

const generateBackupCodes = (count = 10) => {
    const codes = [];
    for (let i = 0; i < count; i++) {
        const code = Math.floor(Math.random() * 100000000).toString().padStart(8, '0');
        codes.push(code);
    }
    return codes;
}

function ResetAccessCodesFlow({ isOpen, onOpenChange }: { isOpen: boolean, onOpenChange: (open: boolean) => void }) {
    const [step, setStep] = React.useState(1);
    const [progress, setProgress] = React.useState(0);
    const [isReconfiguring, setIsReconfiguring] = React.useState(false);

    React.useEffect(() => {
        if (step === 1 && isOpen) {
            const timer = setTimeout(() => setProgress(100), 500);
            const stepTimer = setTimeout(() => setStep(2), 1500);
            return () => {
                clearTimeout(timer);
                clearTimeout(stepTimer);
            };
        }
    }, [step, isOpen]);

    const handleReconfigure = () => {
        setIsReconfiguring(true);
        onOpenChange(false);
    }
    
    const renderStep = () => {
        switch (step) {
            case 1:
                return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-red-500 tracking-widest">EMERGENCY ACCESS PROTOCOL</DialogTitle>
                        </DialogHeader>
                        <div className="text-center font-code text-red-400 space-y-4 p-4">
                            <p>&gt; [WARNING] BREACH DETECTED</p>
                            <p>&gt; ACTIVATING_EMERGENCY_PROTOCOLS...</p>
                            <Progress value={progress} className="w-full h-2 bg-red-500/20 border-none [&>*]:bg-red-500" />
                            {progress === 100 && <p className="animate-pulse">&gt; NETRUNNER_IDENTITY_VERIFICATION_REQUIRED</p>}
                        </div>
                    </div>
                );
            case 2:
                 return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-yellow-400 tracking-widest">NEURAL PATTERN VERIFICATION</DialogTitle>
                        </DialogHeader>
                        <div className="p-4 space-y-4">
                            <Label htmlFor="backup-code" className="terminal-label text-yellow-400">&gt; EMERGENCY_BACKUP_CODE_REQUIRED:</Label>
                            <Input id="backup-code" placeholder="________" className="terminal-input text-2xl tracking-[0.5em] text-center border-yellow-400" maxLength={8} />
                            <div className="text-xs text-center text-yellow-600 font-code">
                                <p>REMAINING_EMERGENCY_CODES: 7/10</p>
                                <p>SECURITY_LEVEL: CRITICAL_RED</p>
                            </div>
                            <Button onClick={() => setStep(3)} className="w-full terminal-button border-yellow-400 text-yellow-400">VERIFY IDENTITY</Button>
                        </div>
                    </div>
                );
            case 3:
                return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">ACCESS CODE RECONFIGURATION</DialogTitle>
                        </DialogHeader>
                        <div className="p-4 space-y-4">
                            <Label htmlFor="new-reset-access-code" className="terminal-label">&gt; NEW_ACCESS_CODE:</Label>
                            <Input id="new-reset-access-code" type="password" placeholder="[****************]" className="terminal-input" />
                             <Label htmlFor="confirm-reset-access-code" className="terminal-label">&gt; CONFIRM_ACCESS_CODE:</Label>
                            <Input id="confirm-reset-access-code" type="password" placeholder="[****************]" className="terminal-input" />
                            <Button onClick={() => setStep(4)} className="w-full terminal-button">SET_NEW_CODE</Button>
                        </div>
                    </div>
                );
            case 4:
                return (
                     <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">NEURAL SECURITY UPGRADE</DialogTitle>
                        </DialogHeader>
                        <div className="p-4 space-y-4 font-code text-sm">
                            <Button variant="outline" className="w-full h-auto text-left flex flex-col items-start p-3" onClick={() => onOpenChange(false)}>
                                <span className="font-bold text-primary">MAINTAIN_CURRENT_2FA</span>
                                <span className="text-muted-foreground text-xs">Keep existing authenticator setup.</span>
                            </Button>
                             <Button variant="outline" className="w-full h-auto text-left flex flex-col items-start p-3 border-yellow-400 text-yellow-400" onClick={handleReconfigure}>
                                <span className="font-bold">RECONFIGURE_NEURAL_LINK</span>
                                <span className="text-yellow-600 text-xs">[RECOMMENDED] Generate new QR code & backup codes.</span>
                            </Button>
                             <Button variant="destructive" className="w-full h-auto text-left flex flex-col items-start p-3">
                                <span className="font-bold">DISABLE_2FA_TEMPORARILY</span>
                                <span className="text-red-300 text-xs">[DANGER] Reduced security level.</span>
                            </Button>
                        </div>
                    </div>
                );
        }
    };
    
    return (
        <>
            <Dialog open={isOpen} onOpenChange={(open) => { if (!isReconfiguring) onOpenChange(open); }}>
                <DialogContent className="bg-black/80 border-2 border-primary/50 text-white font-code backdrop-blur-sm" style={{ boxShadow: '0 0 25px hsl(var(--primary)), inset 0 0 15px hsl(var(--primary) / 0.5)' }}>
                    {renderStep()}
                </DialogContent>
            </Dialog>
            <TotpSetupPopup isOpen={isReconfiguring} onOpenChange={setIsReconfiguring} username="your_netrunner_id" password="dummy_password" />
        </>
    );
}

function TotpSetupPopup({ isOpen, onOpenChange, username, password }: { isOpen: boolean, onOpenChange: (open: boolean) => void, username: string, password?: string }) {
    const { toast } = useToast();
    const [step, setStep] = React.useState(1);
    const [progress, setProgress] = React.useState(0);
    const [secret, setSecret] = React.useState('');
    const [qrCodeDataUrl, setQrCodeDataUrl] = React.useState('');
    const [isKeyVisible, setIsKeyVisible] = React.useState(false);
    const [backupCodes, setBackupCodes] = React.useState<string[]>([]);
    const [verificationStatus, setVerificationStatus] = React.useState<'pending' | 'valid' | 'invalid'>('pending');
    const [totpInput, setTotpInput] = React.useState('');
    const [isSubmitting, setIsSubmitting] = React.useState(false);

    React.useEffect(() => {
        if (isOpen) {
            setStep(1);
            setProgress(0);
            const newSecret = generateRandomSecret();
            setSecret(newSecret);
            setBackupCodes(generateBackupCodes());
            setTotpInput('');
            setVerificationStatus('pending');
            setIsSubmitting(false);

            const timer = setTimeout(() => setProgress(100), 500);
            const stepTimer = setTimeout(() => setStep(2), 1500);
            return () => {
                clearTimeout(timer);
                clearTimeout(stepTimer);
            };
        }
    }, [isOpen]);

    React.useEffect(() => {
        if (isOpen && secret && username) {
            const serviceName = "NeuroLink";
            const totp = new OTPAuth.TOTP({
                issuer: serviceName,
                label: username,
                algorithm: 'SHA1',
                digits: 6,
                period: 30,
                secret: OTPAuth.Secret.fromBase32(secret),
            });
            const qrData = totp.toString();

            QRCode.toDataURL(qrData, {
                errorCorrectionLevel: 'H',
                margin: 2,
                color: {
                    dark: '#00FF9F',
                    light: '#00000000'
                }
            })
            .then(url => {
                setQrCodeDataUrl(url);
            })
            .catch(err => {
                console.error(err);
            });
        }
    }, [isOpen, secret, username]);

    const handleVerification = async () => {
        if (!secret || totpInput.length !== 6 || !password) {
            return;
        }
        
        setIsSubmitting(true);

        try {
            const totp = new OTPAuth.TOTP({
                issuer: "NeuroLink",
                label: username,
                algorithm: 'SHA1',
                digits: 6,
                period: 30,
                secret: OTPAuth.Secret.fromBase32(secret), 
            });

            let delta = totp.validate({ token: totpInput, window: 1 });

            if (delta === null) {
                setVerificationStatus('invalid');
                toast({
                    title: "[ERROR] INVALID_VERIFICATION_CODE",
                    description: "Neural pattern mismatch. Recalibrate and try again.",
                    variant: "destructive",
                });
                setIsSubmitting(false);
                return;
            }

            setVerificationStatus('valid');
            
            // API Call
            const response = await fetch('/api/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username,
                    password,
                    'secret-key': secret,
                }),
            });

            if (!response.ok) {
                const errorData = await response.json();
                const errorTitle = errorData.error ? `[${errorData.error.toUpperCase()}]` : "[REGISTRATION_FAULT]";
                toast({
                    title: errorTitle,
                    description: errorData.message || "An unknown error occurred during registration.",
                    variant: "destructive",
                });
                setIsSubmitting(false);
                return;
            }

            const responseData = await response.json();
            toast({
                title: "[SUCCESS] REGISTRATION_COMPLETE",
                description: `Netrunner profile ${responseData.username} created. Welcome to the grid.`,
            });
            
            setTimeout(() => setStep(5), 1000);

        } catch (e: any) {
            console.error("Verification or API error:", e);
            toast({
                title: "[SYSTEM_FAULT] REGISTRATION_ERROR",
                description: e.message || "Anomaly detected in the quantum entanglement. Contact support.",
                variant: "destructive",
            });
        } finally {
            setIsSubmitting(false);
        }
    };


    const renderStep = () => {
        switch (step) {
            case 1:
                return (
                    <div className="text-center font-code text-primary space-y-4">
                        <p>&gt; NETRUNNER DETECTED - ENHANCED SECURITY REQUIRED</p>
                        <p>&gt; GENERATING QUANTUM ENCRYPTION KEY...</p>
                        <Progress value={progress} className="w-full h-2 bg-primary/20 border-none [&>*]:bg-primary" />
                        {progress === 100 && <p className="animate-pulse">&gt; [SUCCESS] NEURAL LINK SECURITY ACTIVATED</p>}
                    </div>
                );
            case 2:
                return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">Biometric Authenticator Setup</DialogTitle>
                        </DialogHeader>
                        <div className="flex flex-col items-center gap-6 p-4">
                            <div className="p-2 border-2 border-primary/50" style={{ boxShadow: '0 0 15px hsl(var(--primary))' }}>
                                {qrCodeDataUrl ? <img src={qrCodeDataUrl} alt="TOTP QR Code" className="w-48 h-48" /> : <div className="w-48 h-48 bg-gray-800 animate-pulse" />}
                            </div>
                            <div className="w-full space-y-2 text-center">
                                <Button onClick={() => setIsKeyVisible(!isKeyVisible)} variant="outline" className="terminal-button w-full">
                                    {isKeyVisible ? <EyeOff className="mr-2"/> : <Eye className="mr-2"/>}
                                    {isKeyVisible ? 'HIDE_QUANTUM_KEY' : 'REVEAL_QUANTUM_KEY'}
                                </Button>
                                {isKeyVisible && (
                                    <div className="p-2 bg-black/50 border border-primary/30 font-code text-primary break-all flex items-center justify-between">
                                        <span>{secret}</span>
                                        <Button size="icon" variant="ghost" onClick={() => navigator.clipboard.writeText(secret)}>
                                            <Copy className="h-4 w-4" />
                                        </Button>
                                    </div>
                                )}
                            </div>
                            <Button onClick={() => setStep(3)} className="w-full terminal-button">NEXT_PROTOCOL</Button>
                        </div>
                    </div>
                );
            case 3:
                return (
                     <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">Authenticator Instructions</DialogTitle>
                        </DialogHeader>
                        <div className="font-code text-sm text-primary/80 space-y-4 p-4 [&_ul]:list-disc [&_ul]:pl-6">
                            <p>&gt; COMPATIBLE NEURAL INTERFACES:</p>
                            <ul>
                                <li>GOOGLE_AUTHENTICATOR</li>
                                <li>MICROSOFT_AUTHENTICATOR</li>
                                <li>AUTHY_SYSTEM</li>
                                <li>1PASSWORD_VAULT</li>
                            </ul>
                            <p>&gt; INSTALLATION_PROTOCOL:</p>
                            <ol className="list-decimal pl-6">
                                <li>SCAN_QR_CODE with authenticator app</li>
                                <li>OR ENTER_MANUAL_KEY if scanner unavailable</li>
                                <li>VERIFY_6_DIGIT_CODE in next step</li>
                            </ol>
                        </div>
                        <Button onClick={() => setStep(4)} className="w-full terminal-button mt-4">PROCEED_TO_VERIFICATION</Button>
                    </div>
                );
             case 4:
                const getBorderColor = () => {
                    if (verificationStatus === 'valid') return 'border-primary';
                    if (verificationStatus === 'invalid') return 'border-destructive';
                    return 'border-primary/50';
                }
                return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">Neural Link Verification</DialogTitle>
                        </DialogHeader>
                        <div className="p-4 space-y-4">
                            <Label htmlFor="totp-code" className="terminal-label">&gt; ENTER_6_DIGIT_VERIFICATION_CODE:</Label>
                            <Input 
                                id="totp-code" 
                                placeholder="000000" 
                                className={`terminal-input text-2xl tracking-[0.5em] text-center ${getBorderColor()}`}
                                maxLength={6}
                                value={totpInput}
                                onChange={(e) => {
                                    setVerificationStatus('pending');
                                    setTotpInput(e.target.value);
                                }}
                            />
                            <Button onClick={handleVerification} className="w-full terminal-button" disabled={totpInput.length !== 6 || isSubmitting}>
                                {isSubmitting ? 'VERIFYING...' : 'VERIFY_LINK'}
                            </Button>
                        </div>
                    </div>
                );
            case 5:
                return (
                    <div>
                        <DialogHeader>
                            <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">Emergency Backup Protocols</DialogTitle>
                        </DialogHeader>
                        <div className="p-4 font-code text-primary">
                            <p className="text-yellow-400 mb-2">[WARNING] STORE_SECURELY - ONE_USE_ONLY</p>
                            <div className="grid grid-cols-2 gap-2 p-2 border border-primary/30 bg-black/50">
                                {backupCodes.map((code, index) => <div key={index}>{code}</div>)}
                            </div>
                        </div>
                         <Button onClick={() => onOpenChange(false)} className="w-full terminal-button mt-4">SETUP_COMPLETE</Button>
                    </div>
                );
        }
    };
    
    return (
        <Dialog open={isOpen} onOpenChange={onOpenChange}>
            <DialogContent className="bg-black/80 border-2 border-primary/50 text-white font-code backdrop-blur-sm" style={{ boxShadow: '0 0 25px hsl(var(--primary)), inset 0 0 15px hsl(var(--primary) / 0.5)' }}>
                {step === 1 && (
                    <DialogHeader>
                        <DialogTitle className="font-headline text-lg uppercase text-center text-primary tracking-widest">Neural Security Protocol - Initializing 2FA</DialogTitle>
                    </DialogHeader>
                )}
                {renderStep()}
            </DialogContent>
        </Dialog>
    )
}

export function MatrixRain() {
  const canvasRef = React.useRef<HTMLCanvasElement>(null);

  React.useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let w = canvas.width = window.innerWidth;
    let h = canvas.height = window.innerHeight;
    let ypos: number[] = Array(300).fill(0);

    const matrix = () => {
      ctx.fillStyle = 'rgba(0,0,0,.05)';
      ctx.fillRect(0,0,w,h);
      ctx.fillStyle = '#0F0';
      ctx.font = '15pt monospace';

      ypos.forEach((y, ind) => {
        const text = String.fromCharCode(Math.random()*128);
        const x = ind * 20;
        ctx.fillText(text, x, y);
        if(y > 100 + Math.random()*10000) ypos[ind] = 0;
        else ypos[ind] = y + 20;
      });
    }

    let interval = setInterval(matrix, 60);

    const handleResize = () => {
      w = canvas.width = window.innerWidth;
      h = canvas.height = window.innerHeight;
      ypos = Array(Math.floor(w / 20)).fill(0);
    };
    window.addEventListener('resize', handleResize);

    return () => {
      clearInterval(interval);
      window.removeEventListener('resize', handleResize);
    }
  }, []);

  return <canvas ref={canvasRef} className="absolute top-0 left-0 w-full h-full z-0"></canvas>;
}
