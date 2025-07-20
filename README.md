

# Clairvoyant: Multi-Agent LLM Financial Trading Framework & Dashboard

> 🎉 **Clairvoyant** officially released! Unified multi-agent trading framework and dashboard.


---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Backend Setup](#backend-setup)
- [API Integration Guide](#api-integration-guide)
- [Component Features](#component-features)
- [Frontend Setup](#frontend-setup)
- [CLI Usage](#cli-usage)
- [Python Usage](#python-usage)
- [API Endpoints](#api-endpoints)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Citation](#citation)
- [License](#license)

## Overview
Clairvoyant is a unified platform combining a multi-agent LLM financial trading framework and a modern Next.js dashboard.

## Features
- **Multi-Agent Framework**: Deploys specialized agents for fundamentals, sentiment, news, and technical analysis.
- **Researcher Debates**: Bullish and bearish researchers engage in structured debates for balanced insights.
- **Trader & Risk Management**: Trader agent executes decisions; risk and portfolio managers ensure safety and compliance.
- **Unified Dashboard**: Real-time charts, technical indicators, and AI recommendations via a Next.js interface.
- **Flexible Deployment**: Python package, CLI, FastAPI backend, and Next.js frontend.

## Architecture
```text
Frontend (Next.js) → FastAPI API → Clairvoyant Agents → External Data Sources
```

## Installation
```bash
git clone https://github.com/TauricResearch/TradingAgents.git
cd TradingAgents
```

## Backend Setup
1. Create and activate a Python environment:
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Set environment variables:
   ```bash
   export FINNHUB_API_KEY=$YOUR_FINNHUB_API_KEY
   export OPENAI_API_KEY=$YOUR_OPENAI_API_KEY
   ```
4. Start the API server:
   ```bash
   # Development
   python [`main.py`](main.py)
   # Production ASGI
   uvicorn [`tradingagents/api/main.py`](tradingagents/api/main.py):app --host 0.0.0.0 --port 8000 --workers 4
   ```

## API Integration Guide
### What's Been Created
- **FastAPI Web Server**: Complete REST API endpoints for:
  - Stock chart data
  - Technical indicators
  - Trade recommendations
  - Health check
- **Unified Dashboard Components**: React components updated to fetch real data, handle loading and errors, and use TypeScript interfaces.

### Setup Instructions
#### 1. Install Dependencies
- Python:
  ```bash
  pip install fastapi uvicorn
  # Or use existing:
  pip install -r requirements.txt
  ```
- Frontend:
  ```bash
  cd frontend
  npm install react @types/react lucide-react
  ```
- UI Library Setup:
  ```bash
  npx shadcn-ui init
  npx shadcn-ui add card badge button progress
  ```

#### 2. Start the API Server
```bash
python tradingagents/api/main.py
# Or with reload:
uvicorn tradingagents/api/main:app --reload
```
Server at http://localhost:8000, docs at http://localhost:8000/docs.

#### 3. Frontend Environment Variables
Create a `.env.local` in the `frontend` directory:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

#### 4. Using the Components
```tsx
import StockChart from './components/StockChart'
import TechnicalIndicators from './components/TechnicalIndicators'
import TradeRecommendations from './components/TradeRecommendations'

function TradingDashboard() {
  const symbol = 'AAPL'
  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div className="lg:col-span-2"><StockChart symbol={symbol} /></div>
      <div><TechnicalIndicators symbol={symbol} /></div>
      <div><TradeRecommendations symbol={symbol} /></div>
    </div>
  )
}
export default TradingDashboard
```

#### 5. CORS Configuration
Configure in [`tradingagents/api/main.py`](tradingagents/api/main.py:128-136):
```python
app.add_middleware(
  CORSMiddleware,
  allow_origins=["http://localhost:3000"],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)
```

## Component Features
### StockChart Component
- Real-time price and volume, change, historical chart with levels.
- Interactive SVG rendering.
- Loading states and errors.

### TechnicalIndicators Component
- Live RSI, MACD, Bollinger Bands, and ATR.
- Trend analysis with progress bars and icons.
- Aggregated bullish/bearish signal.

### TradeRecommendations Component
- AI-powered trade suggestions with risk metrics.
- Stop-loss, take-profit, position sizing.
- Recent trade history and performance.

## Frontend Setup
```bash
cd frontend
npm install
npm run dev      # start dev server
npm run build && npm run start  # production
```

## CLI Usage
```bash
python -m cli.main
```

## Python Usage
```python
from tradingagents.graph.trading_graph import TradingAgentsGraph
from tradingagents.default_config import DEFAULT_CONFIG

ta = TradingAgentsGraph(debug=True, config=DEFAULT_CONFIG.copy())
_, decision = ta.propagate("NVDA", "2024-05-10")
print(decision)
```

## API Endpoints
- `GET /api/stock/{symbol}/chart` - price, volume, chart, levels.
- `GET /api/stock/{symbol}/technical-indicators?date=YYYY-MM-DD` - RSI, MACD, moving averages, signal.
- `GET /api/stock/{symbol}/trade-recommendations?date=YYYY-MM-DD` - recommendations, risk, history.
- `GET /api/health` - status and timestamp.
