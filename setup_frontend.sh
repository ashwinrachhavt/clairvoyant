#!/bin/bash

# TradingAgents Frontend Setup Script
# This script will create a complete Next.js project with shadcn/ui and integrate with the backend

set -e  # Exit on any error

echo "🚀 Setting up TradingAgents Frontend..."
echo "========================================"

# Check if we're in the right directory
if [ ! -f "api/main.py" ]; then
    echo "❌ Error: Please run this script from the TradingAgents project root directory"
    echo "   Make sure api/main.py exists"
    exit 1
fi

# Create frontend directory
echo "📁 Creating frontend directory..."
if [ -d "frontend" ]; then
    echo "⚠️  Frontend directory already exists. Removing it..."
    rm -rf frontend
fi

# Create Next.js project
echo "🔧 Creating Next.js 15 project with TypeScript and Tailwind..."
npx create-next-app@latest frontend \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --use-npm \
    --yes

cd frontend

echo "✅ Next.js project created successfully!"

# Initialize shadcn/ui
echo "🎨 Initializing shadcn/ui..."
npx shadcn@latest init --yes --defaults

echo "✅ shadcn/ui initialized!"

# Install required shadcn components
echo "📦 Installing shadcn UI components..."
npx shadcn@latest add card badge button progress --yes

echo "✅ UI components installed!"

# Install additional dependencies
echo "📦 Installing additional dependencies..."
npm install lucide-react next-themes

echo "✅ Additional dependencies installed!"

# Create components directory and move our trading components
echo "📂 Setting up trading components..."
mkdir -p src/components/trading

# Copy our modified components to the frontend
cp ../components/StockChart.tsx src/components/trading/
cp ../components/TechnicalIndicators.tsx src/components/trading/
cp ../components/TradeRecommendations.tsx src/components/trading/

echo "✅ Trading components copied!"

# Create a theme provider
echo "🌙 Setting up theme provider..."
cat > src/components/theme-provider.tsx << 'EOF'
"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

# Create layout with theme provider
echo "🔧 Setting up app layout..."
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { ThemeProvider } from "@/components/theme-provider"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "TradingAgents Dashboard",
  description: "AI-powered trading analysis and recommendations",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF

# Create main dashboard page
echo "📱 Creating main dashboard page..."
cat > src/app/page.tsx << 'EOF'
"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { TrendingUp, BarChart3, Target } from "lucide-react"
import StockChart from "@/components/trading/StockChart"
import TechnicalIndicators from "@/components/trading/TechnicalIndicators"
import TradeRecommendations from "@/components/trading/TradeRecommendations"

export default function TradingDashboard() {
  const [symbol, setSymbol] = useState("AAPL")
  const [inputSymbol, setInputSymbol] = useState("AAPL")

  const handleSymbolChange = () => {
    if (inputSymbol.trim()) {
      setSymbol(inputSymbol.trim().toUpperCase())
    }
  }

  const popularStocks = ["AAPL", "GOOGL", "MSFT", "TSLA", "NVDA", "AMZN", "META", "NFLX"]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      {/* Header */}
      <div className="border-b border-slate-800 bg-slate-900/50 backdrop-blur">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="flex items-center space-x-2">
                <BarChart3 className="h-8 w-8 text-blue-500" />
                <h1 className="text-2xl font-bold text-white">TradingAgents</h1>
              </div>
              <Badge variant="outline" className="text-blue-400 border-blue-400/20">
                AI-Powered
              </Badge>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Input
                  placeholder="Enter symbol (e.g., AAPL)"
                  value={inputSymbol}
                  onChange={(e) => setInputSymbol(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSymbolChange()}
                  className="w-48"
                />
                <Button onClick={handleSymbolChange} size="sm">
                  Analyze
                </Button>
              </div>
            </div>
          </div>
          
          {/* Popular Stocks */}
          <div className="flex flex-wrap gap-2 mt-4">
            <span className="text-sm text-slate-400">Popular:</span>
            {popularStocks.map((stock) => (
              <Button
                key={stock}
                variant={symbol === stock ? "default" : "outline"}
                size="sm"
                onClick={() => {
                  setSymbol(stock)
                  setInputSymbol(stock)
                }}
                className="text-xs"
              >
                {stock}
              </Button>
            ))}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Stock Chart - Full Width */}
          <div className="lg:col-span-2">
            <Card className="bg-slate-900/50 border-slate-800">
              <CardHeader>
                <CardTitle className="text-white flex items-center">
                  <TrendingUp className="h-5 w-5 mr-2" />
                  {symbol} Stock Analysis
                </CardTitle>
              </CardHeader>
              <CardContent>
                <StockChart symbol={symbol} />
              </CardContent>
            </Card>
          </div>

          {/* Technical Indicators */}
          <div>
            <TechnicalIndicators symbol={symbol} />
          </div>

          {/* Trade Recommendations */}
          <div>
            <TradeRecommendations symbol={symbol} />
          </div>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center">
          <div className="inline-flex items-center space-x-2 text-slate-500 text-sm">
            <Target className="h-4 w-4" />
            <span>Powered by TradingAgents AI Framework</span>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# Install Input component for the search
echo "📦 Installing Input component..."
npx shadcn@latest add input --yes

# Update globals.css for dark theme support
echo "🎨 Updating global styles..."
cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.5rem;
    --chart-1: 12 76% 61%;
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 84% 4.9%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 94.1%;
    --chart-1: 220 70% 50%;
    --chart-2: 160 60% 45%;
    --chart-3: 30 80% 55%;
    --chart-4: 280 65% 60%;
    --chart-5: 340 75% 55%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

/* Custom scrollbar for dark theme */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: rgb(15 23 42);
}

::-webkit-scrollbar-thumb {
  background: rgb(51 65 85);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgb(71 85 105);
}
EOF

# Create API configuration
echo "🔗 Creating API configuration..."
mkdir -p src/lib
cat > src/lib/api.ts << 'EOF'
// API configuration for TradingAgents backend
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export const api = {
  stock: {
    chart: (symbol: string) => `${API_BASE_URL}/api/stock/${symbol}/chart`,
    technicalIndicators: (symbol: string, date?: string) => 
      `${API_BASE_URL}/api/stock/${symbol}/technical-indicators${date ? `?date=${date}` : ''}`,
    tradeRecommendations: (symbol: string, date?: string) => 
      `${API_BASE_URL}/api/stock/${symbol}/trade-recommendations${date ? `?date=${date}` : ''}`,
  },
  health: () => `${API_BASE_URL}/api/health`,
}
EOF

# Update package.json with proper scripts
echo "📜 Updating package.json..."
cat > package.json << 'EOF'
{
  "name": "tradingagents-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "backend": "cd .. && python api/main.py",
    "full-dev": "concurrently \"npm run backend\" \"npm run dev\""
  },
  "dependencies": {
    "next": "15.2.1",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "@radix-ui/react-aspect-ratio": "^1.1.1",
    "@radix-ui/react-dialog": "^1.1.5",
    "@radix-ui/react-dropdown-menu": "^2.1.4",
    "@radix-ui/react-label": "^2.1.1",
    "@radix-ui/react-popover": "^1.1.5",
    "@radix-ui/react-progress": "^1.1.1",
    "@radix-ui/react-select": "^2.1.4",
    "@radix-ui/react-separator": "^1.1.1",
    "@radix-ui/react-slot": "^1.1.1",
    "@radix-ui/react-tabs": "^1.1.1",
    "@radix-ui/react-toast": "^1.2.3",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "lucide-react": "^0.469.0",
    "next-themes": "^0.4.4",
    "tailwind-merge": "^2.7.0",
    "tailwindcss-animate": "^1.0.7"
  },
  "devDependencies": {
    "@types/node": "^22.10.5",
    "@types/react": "^19.0.2",
    "@types/react-dom": "^19.0.2",
    "eslint": "^8.57.1",
    "eslint-config-next": "15.2.1",
    "postcss": "^8.5.1",
    "tailwindcss": "^3.4.17",
    "typescript": "^5.7.2",
    "concurrently": "^9.1.0"
  }
}
EOF

# Install concurrently for running both frontend and backend
echo "📦 Installing concurrently for full-stack development..."
npm install --save-dev concurrently

# Create environment file
echo "🔧 Creating environment configuration..."
cat > .env.local << 'EOF'
# TradingAgents API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000

# Development settings
NODE_ENV=development
EOF

# Create README for the frontend
echo "📚 Creating frontend README..."
cat > README.md << 'EOF'
# TradingAgents Frontend

A modern Next.js dashboard for the TradingAgents AI trading framework.

## Features

- 🎨 **Modern UI**: Built with Next.js 15, shadcn/ui, and Tailwind CSS
- 🌙 **Dark Mode**: Native dark theme support
- 📊 **Real-time Data**: Live stock charts and technical indicators
- 🤖 **AI Recommendations**: Powered by TradingAgents framework
- 📱 **Responsive**: Works on desktop and mobile

## Quick Start

```bash
# Install dependencies
npm install

# Start development server (frontend only)
npm run dev

# Start full-stack development (backend + frontend)
npm run full-dev
```

Open [http://localhost:3000](http://localhost:3000) to view the dashboard.

## Available Scripts

- `npm run dev` - Start Next.js development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run backend` - Start the Python API backend
- `npm run full-dev` - Start both backend and frontend

## Environment Variables

Create a `.env.local` file:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Architecture

```
Frontend (Next.js) → API (FastAPI) → TradingAgents → Market Data
```

The frontend communicates with the FastAPI backend which uses the TradingAgents framework to provide AI-powered trading analysis.
EOF

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "📄 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Dependencies
/node_modules
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env*.local

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts
EOF
fi

cd ..

echo ""
echo "🎉 Frontend setup complete!"
echo "=========================="
echo ""
echo "📁 Project structure:"
echo "   TradingAgents/"
echo "   ├── api/                 # Python FastAPI backend"
echo "   ├── frontend/            # Next.js frontend"
echo "   ├── components/          # Original React components"
echo "   └── tradingagents/       # Core trading framework"
echo ""
echo "🚀 Next steps:"
echo "   1. Start the backend:    cd TradingAgents && python api/main.py"
echo "   2. Start the frontend:   cd frontend && npm run dev"
echo "   3. Or run both together: cd frontend && npm run full-dev"
echo ""
echo "🌐 URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "✨ Features included:"
echo "   ✅ Modern Next.js 15 with TypeScript"
echo "   ✅ shadcn/ui components"
echo "   ✅ Dark theme support"
echo "   ✅ Tailwind CSS styling"
echo "   ✅ API integration"
echo "   ✅ Stock symbol search"
echo "   ✅ Popular stocks shortcuts"
echo "   ✅ Real-time data fetching"
echo "   ✅ Error handling & loading states"
echo "" 