"use client";

import { cn } from "@/lib/utils";
import * as React from "react";

interface CyberpunkBorderProps extends React.HTMLAttributes<HTMLDivElement> {
  as?: React.ElementType;
}

export const CyberpunkBorder = React.forwardRef<
  HTMLDivElement,
  CyberpunkBorderProps
>(({ className, as: Comp = "div", style, ...props }, ref) => {
  const defaultClipPath = 'polygon(8px 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, 8px 100%, 0 calc(100% - 8px))';

  return (
    <Comp
      ref={ref}
      className={cn(
        "cyber-border",
        className
      )}
      style={{
        clipPath: defaultClipPath,
        ...style,
      }}
      {...props}
    />
  );
});

CyberpunkBorder.displayName = "CyberpunkBorder";
