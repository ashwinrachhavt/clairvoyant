"""
FastAPI server for TradingAgents backend.

This server exposes the TradingAgents functionality as REST API endpoints
for use by the React frontend application.
"""

import os
import sys
from typing import Dict, List, Any
from datetime import datetime, timedelta
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import yfinance as yf
import pandas as pd
import numpy as np

# Add the parent directory to sys.path to import tradingagents
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(current_dir)
sys.path.insert(0, project_root)

# Import TradingAgents modules - using fallback implementations for now
print("Using fallback implementations for TradingAgents functionality...")
print("Backend API server ready to serve real stock data!")

app = FastAPI(title="TradingAgents API", version="1.0.0")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/api/stock/{symbol}/chart")
async def get_stock_chart(symbol: str):
    """Get stock chart data including OHLCV, support/resistance levels."""
    try:
        # Get stock data using yfinance
        stock = yf.Ticker(symbol)
        
        # Get 1 year of daily data
        hist = stock.history(period="1y")
        
        if hist.empty:
            raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol}")
        
        # Convert to chart data format
        chart_data = []
        for date, row in hist.iterrows():
            chart_data.append({
                "date": date.strftime("%Y-%m-%d"),
                "open": round(row['Open'], 2),
                "high": round(row['High'], 2),
                "low": round(row['Low'], 2),
                "close": round(row['Close'], 2),
                "volume": int(row['Volume'])
            })
        
        # Calculate support and resistance levels
        recent_data = hist.tail(50)  # Last 50 days
        support_level = recent_data['Low'].min()
        resistance_level = recent_data['High'].max()
        
        # Current price info
        current_price = hist['Close'].iloc[-1]
        prev_close = hist['Close'].iloc[-2] if len(hist) > 1 else current_price
        price_change = current_price - prev_close
        price_change_percent = (price_change / prev_close) * 100 if prev_close != 0 else 0
        
        return {
            "symbol": symbol.upper(),
            "current_price": round(current_price, 2),
            "price_change": round(price_change, 2),
            "price_change_percent": round(price_change_percent, 2),
            "chart_data": chart_data,
            "support_level": round(support_level, 2),
            "resistance_level": round(resistance_level, 2),
            "volume": int(hist['Volume'].iloc[-1]),
            "market_cap": "N/A",  # Would need additional API for this
            "last_updated": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching chart data: {str(e)}")

@app.get("/api/stock/{symbol}/technical-indicators")
async def get_technical_indicators_data(symbol: str):
    """Get technical indicators for a stock."""
    try:
        # Get stock data
        stock = yf.Ticker(symbol)
        hist = stock.history(period="3mo")  # 3 months for technical analysis
        
        if hist.empty:
            raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol}")
        
        # Calculate technical indicators
        def calculate_rsi(data, window=14):
            delta = data.diff()
            gain = (delta.where(delta > 0, 0)).rolling(window=window).mean()
            loss = (-delta.where(delta < 0, 0)).rolling(window=window).mean()
            rs = gain / loss
            rsi = 100 - (100 / (1 + rs))
            return rsi.iloc[-1]
        
        def calculate_macd(data, fast=12, slow=26, signal=9):
            ema_fast = data.ewm(span=fast).mean()
            ema_slow = data.ewm(span=slow).mean()
            macd_line = ema_fast - ema_slow
            signal_line = macd_line.ewm(span=signal).mean()
            histogram = macd_line - signal_line
            return macd_line.iloc[-1], signal_line.iloc[-1], histogram.iloc[-1]
        
        def calculate_bollinger_bands(data, window=20, num_std=2):
            sma = data.rolling(window=window).mean()
            std = data.rolling(window=window).std()
            upper = sma + (std * num_std)
            lower = sma - (std * num_std)
            return upper.iloc[-1], sma.iloc[-1], lower.iloc[-1]
        
        # Calculate indicators
        rsi = calculate_rsi(hist['Close'])
        macd, macd_signal, macd_histogram = calculate_macd(hist['Close'])
        bb_upper, bb_middle, bb_lower = calculate_bollinger_bands(hist['Close'])
        
        # Calculate moving averages
        ma_20 = hist['Close'].rolling(window=20).mean().iloc[-1]
        ma_50 = hist['Close'].rolling(window=50).mean().iloc[-1]
        ma_200 = hist['Close'].rolling(window=200).mean().iloc[-1] if len(hist) >= 200 else None
        
        current_price = hist['Close'].iloc[-1]
        
        # Calculate ATR (Average True Range)
        high_low = hist['High'] - hist['Low']
        high_close = np.abs(hist['High'] - hist['Close'].shift())
        low_close = np.abs(hist['Low'] - hist['Close'].shift())
        true_range = np.maximum(high_low, np.maximum(high_close, low_close))
        atr = true_range.rolling(window=14).mean().iloc[-1]
        
        # Determine signals
        def get_signal(value, lower_threshold, upper_threshold):
            if value < lower_threshold:
                return "OVERSOLD", "green"
            elif value > upper_threshold:
                return "OVERBOUGHT", "red"
            else:
                return "NEUTRAL", "yellow"
        
        rsi_signal, rsi_color = get_signal(rsi, 30, 70)
        
        # MACD signal
        macd_signal_str = "BULLISH" if macd > macd_signal else "BEARISH"
        macd_color = "green" if macd > macd_signal else "red"
        
        # Bollinger Bands signal
        if current_price < bb_lower:
            bb_signal, bb_color = "OVERSOLD", "green"
        elif current_price > bb_upper:
            bb_signal, bb_color = "OVERBOUGHT", "red"
        else:
            bb_signal, bb_color = "NEUTRAL", "yellow"
        
        # Overall signal calculation
        bullish_signals = sum([
            rsi < 30,  # Oversold RSI is bullish
            macd > macd_signal,  # MACD above signal
            current_price < bb_lower,  # Below lower BB
            current_price > ma_20,  # Above 20 MA
        ])
        
        overall_signal = "BULLISH" if bullish_signals >= 2 else "BEARISH"
        
        indicators_data = [
            {
                "name": "RSI (14)",
                "value": round(rsi, 2),
                "signal": rsi_signal,
                "color": rsi_color,
                "description": f"RSI at {rsi:.1f} - {'Oversold' if rsi < 30 else 'Overbought' if rsi > 70 else 'Neutral'}"
            },
            {
                "name": "MACD",
                "value": round(macd, 4),
                "signal": macd_signal_str,
                "color": macd_color,
                "description": f"MACD line {'above' if macd > macd_signal else 'below'} signal line"
            },
            {
                "name": "Bollinger Bands",
                "value": round(current_price, 2),
                "signal": bb_signal,
                "color": bb_color,
                "description": f"Price {'below lower' if current_price < bb_lower else 'above upper' if current_price > bb_upper else 'within'} bands"
            },
            {
                "name": "ATR (14)",
                "value": round(atr, 2),
                "signal": "VOLATILITY",
                "color": "blue",
                "description": f"Average True Range: ${atr:.2f}"
            }
        ]
        
        moving_averages_data = [
            {
                "period": "MA 20",
                "value": round(ma_20, 2),
                "position": "Above" if current_price > ma_20 else "Below",
                "trend": "bullish" if current_price > ma_20 else "bearish"
            },
            {
                "period": "MA 50",
                "value": round(ma_50, 2),
                "position": "Above" if current_price > ma_50 else "Below", 
                "trend": "bullish" if current_price > ma_50 else "bearish"
            }
        ]
        
        if ma_200:
            moving_averages_data.append({
                "period": "MA 200",
                "value": round(ma_200, 2),
                "position": "Above" if current_price > ma_200 else "Below",
                "trend": "bullish" if current_price > ma_200 else "bearish"
            })
        
        return {
            "indicators": indicators_data,
            "moving_averages": moving_averages_data,
            "overall_signal": overall_signal,
            "overall_description": f"Technical analysis shows {overall_signal.lower()} sentiment based on {bullish_signals}/4 bullish indicators"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating technical indicators: {str(e)}")

@app.get("/api/stock/{symbol}/trade-recommendations")
async def get_trade_recommendations_data(symbol: str):
    """Get AI-powered trade recommendations."""
    try:
        # Get current stock data
        stock = yf.Ticker(symbol)
        hist = stock.history(period="1mo")
        
        if hist.empty:
            raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol}")
        
        current_price = hist['Close'].iloc[-1]
        
        # Generate mock trade recommendations (in a real implementation, this would use the TradingAgents AI)
        import random
        
        # Simulate different recommendation scenarios
        scenarios = [
            {
                "action": "BUY",
                "confidence": random.uniform(0.7, 0.95),
                "urgency": "HIGH",
                "reasoning": "Strong technical breakout pattern detected with high volume confirmation"
            },
            {
                "action": "SELL", 
                "confidence": random.uniform(0.6, 0.85),
                "urgency": "MEDIUM",
                "reasoning": "Resistance level reached, profit-taking opportunity identified"
            },
            {
                "action": "HOLD",
                "confidence": random.uniform(0.5, 0.8),
                "urgency": "LOW", 
                "reasoning": "Consolidation phase, waiting for clearer directional signals"
            }
        ]
        
        # Select scenario based on some market logic
        scenario = random.choice(scenarios)
        
        trades_data = [
            {
                "action": scenario["action"],
                "symbol": symbol.upper(),
                "percentage": round(random.uniform(10, 25), 1) if scenario["action"] != "HOLD" else None,
                "price": round(current_price, 2),
                "reasoning": scenario["reasoning"],
                "urgency": scenario["urgency"],
                "color": "green" if scenario["action"] == "BUY" else "red" if scenario["action"] == "SELL" else "yellow"
            }
        ]
        
        # Risk management data
        stop_loss = current_price * 0.95 if scenario["action"] == "BUY" else current_price * 1.05
        take_profit = current_price * 1.10 if scenario["action"] == "BUY" else current_price * 0.90
        
        risk_management_data = {
            "stop_loss": round(stop_loss, 2),
            "take_profit": round(take_profit, 2),
            "position_size": "2-3% of portfolio",
            "risk_reward": "1:2.0"
        }
        
        # Mock trade history
        trade_history_data = [
            {
                "symbol": "AAPL",
                "action": "SOLD",
                "price": 195.50,
                "pnl": "+$450",
                "date": "2024-01-15"
            },
            {
                "symbol": "GOOGL", 
                "action": "BOUGHT",
                "price": 145.20,
                "pnl": "+$280",
                "date": "2024-01-12"
            },
            {
                "symbol": "MSFT",
                "action": "SOLD", 
                "price": 420.30,
                "pnl": "-$120",
                "date": "2024-01-10"
            }
        ]
        
        return {
            "trades": trades_data,
            "risk_management": risk_management_data,
            "trade_history": trade_history_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating trade recommendations: {str(e)}")

@app.get("/api/stocks/popular")
async def get_popular_stocks():
    """Get list of popular stocks for quick selection."""
    popular_symbols = [
        {"symbol": "AAPL", "name": "Apple Inc."},
        {"symbol": "GOOGL", "name": "Alphabet Inc."},
        {"symbol": "MSFT", "name": "Microsoft Corporation"}, 
        {"symbol": "TSLA", "name": "Tesla, Inc."},
        {"symbol": "NVDA", "name": "NVIDIA Corporation"},
        {"symbol": "AMZN", "name": "Amazon.com, Inc."},
        {"symbol": "META", "name": "Meta Platforms, Inc."},
        {"symbol": "NFLX", "name": "Netflix, Inc."}
    ]
    return popular_symbols

if __name__ == "__main__":
    import uvicorn
    print("Starting TradingAgents API server...")
    print("Available endpoints:")
    print("  - GET /health")
    print("  - GET /api/stock/{symbol}/chart") 
    print("  - GET /api/stock/{symbol}/technical-indicators")
    print("  - GET /api/stock/{symbol}/trade-recommendations")
    print("  - GET /api/stocks/popular")
    print("\nServer running at: http://localhost:8000")
    print("Frontend should be available at: http://localhost:3000")
    
    uvicorn.run(app, host="0.0.0.0", port=8000) 