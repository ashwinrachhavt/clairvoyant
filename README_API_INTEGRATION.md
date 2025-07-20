# TradingAgents API Integration Guide

This guide explains how to integrate the TradingAgents backend with your React frontend components.

## Overview

I've created a FastAPI web server that exposes your existing TradingAgents functionality as REST API endpoints, and modified your React components to fetch real data instead of using mock data.

## What's Been Created

### 1. FastAPI Web Server (`api/main.py`)

A complete REST API server that provides:

- **Stock Chart Data**: Current price, volume, historical data, support/resistance levels
- **Technical Indicators**: RSI, MACD, moving averages, Bollinger Bands, ATR  
- **Trade Recommendations**: AI-powered trade suggestions, risk management, trade history

### 2. Modified React Components

All three components have been updated to:

- Fetch real data from the API endpoints
- Handle loading states with proper spinners
- Display error states when API calls fail
- Use TypeScript interfaces for type safety

## API Endpoints

### Stock Chart Data
```
GET /api/stock/{symbol}/chart
```
Returns current price, change, volume, chart data, and key levels.

### Technical Indicators  
```
GET /api/stock/{symbol}/technical-indicators?date=YYYY-MM-DD
```
Returns RSI, MACD, moving averages, and overall technical signal.

### Trade Recommendations
```
GET /api/stock/{symbol}/trade-recommendations?date=YYYY-MM-DD  
```
Returns AI-generated trade recommendations, risk management data, and trade history.

### Health Check
```
GET /api/health
```
Returns server status and timestamp.

## Setup Instructions

### 1. Install Dependencies

Add these to your Python environment:
```bash
pip install fastapi uvicorn
```

Or if using the existing requirements.txt:
```bash
pip install -r requirements.txt
```

### 2. Start the API Server

```bash
# From the project root directory
python api/main.py
```

The server will run on `http://localhost:8000`

You can view the interactive API documentation at `http://localhost:8000/docs`

### 3. Frontend Setup

For your React frontend, you'll need these dependencies:

```bash
npm install react @types/react
npm install lucide-react  # For icons
```

For the UI components, you'll need to set up shadcn/ui or similar:

```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add card badge button progress
```

### 4. Using the Components

```tsx
import StockChart from './components/StockChart'
import TechnicalIndicators from './components/TechnicalIndicators'  
import TradeRecommendations from './components/TradeRecommendations'

function TradingDashboard() {
  const symbol = "AAPL" // or any stock symbol
  
  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div className="lg:col-span-2">
        <StockChart symbol={symbol} />
      </div>
      <div>
        <TechnicalIndicators symbol={symbol} />
      </div>
      <div>
        <TradeRecommendations symbol={symbol} />
      </div>
    </div>
  )
}
```

## Configuration

### API Server Configuration

The API server uses your existing TradingAgents configuration. You can modify settings in `api/main.py`:

```python
# Configure CORS for your frontend URL
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Trading Agents Configuration

The API uses your existing `DEFAULT_CONFIG`. You can customize:

- LLM providers and models
- Online vs offline data sources
- Trading analysis parameters

```python
config = DEFAULT_CONFIG.copy()
config["online_tools"] = True  # Enable real-time data
config["llm_provider"] = "openai"  # or "anthropic", "google", etc.
```

## Component Features

### StockChart Component

- **Real-time Price Data**: Current price, change, volume from Yahoo Finance
- **Interactive Chart**: SVG-based price chart with moving averages
- **Key Levels**: Dynamic support, resistance, and target levels
- **Loading States**: Spinner during data fetch
- **Error Handling**: User-friendly error messages

### TechnicalIndicators Component

- **Live Indicators**: RSI, MACD, Bollinger Bands, ATR from your backend
- **Moving Averages**: 50 SMA, 200 SMA with trend analysis
- **Visual Indicators**: Progress bars for RSI, trend icons for moving averages
- **Overall Signal**: Aggregated bullish/bearish assessment

### TradeRecommendations Component

- **AI Recommendations**: Trade suggestions from your TradingAgents framework
- **Risk Management**: Stop loss, take profit, position sizing
- **Trade History**: Recent trade performance
- **Execute Integration**: Ready for trading system integration

## Data Flow

```
Frontend Component → API Endpoint → TradingAgents Backend → External Data Sources
     ↓                    ↓                    ↓                      ↓
React State ← JSON Response ← Analysis Results ← Yahoo Finance/etc
```

## Error Handling

All components handle common errors:

- Network connectivity issues
- Invalid stock symbols  
- API server downtime
- Data parsing errors
- Trading agents analysis failures

## Performance Considerations

- **Caching**: API responses are not cached by default - add Redis or similar for production
- **Rate Limits**: Be mindful of Yahoo Finance rate limits for high-frequency requests
- **Trading Agents**: Full AI analysis can take 30+ seconds - consider background processing
- **WebSockets**: For real-time updates, consider upgrading from REST to WebSocket connections

## Production Deployment

### API Server
```bash
# Production ASGI server
uvicorn api.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Environment Variables
```bash
export TRADINGAGENTS_API_KEY="your-api-key"
export TRADINGAGENTS_ENV="production"
export TRADINGAGENTS_CORS_ORIGINS="https://yourdomain.com"
```

### Docker Deployment
```dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Testing

Test the API endpoints:

```bash
# Test stock chart data
curl http://localhost:8000/api/stock/AAPL/chart

# Test technical indicators  
curl http://localhost:8000/api/stock/AAPL/technical-indicators

# Test trade recommendations
curl http://localhost:8000/api/stock/AAPL/trade-recommendations
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: Update `allow_origins` in the API server
2. **Module Import Errors**: Ensure TradingAgents package is in Python path
3. **Data Source Errors**: Check internet connection and API keys
4. **Component Import Errors**: Install required UI component libraries

### Debug Mode

Enable debug mode for verbose logging:

```python
# In api/main.py
config["debug"] = True
ta = TradingAgentsGraph(debug=True, config=config)
```

## Next Steps

1. **Real-time Updates**: Implement WebSocket connections for live data
2. **Advanced Charts**: Integrate TradingView or similar charting library
3. **Trade Execution**: Connect to actual brokerage APIs
4. **Portfolio Management**: Add portfolio tracking and performance analytics
5. **User Authentication**: Add user accounts and personalized settings

## Support

For issues with the TradingAgents integration, check:

1. The API server logs for backend errors
2. Browser console for frontend errors  
3. Network tab for API request/response details
4. Your TradingAgents configuration and API keys 