#!/usr/bin/env python3
"""
Test script for TradingAgents API endpoints
Run this script to verify the API is working correctly.
"""

import requests
import json
from typing import Dict, Any


def test_endpoint(url: str, endpoint_name: str) -> bool:
    """Test a single API endpoint."""
    try:
        print(f"\n🔍 Testing {endpoint_name}...")
        print(f"   URL: {url}")
        
        response = requests.get(url, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Success! Status: {response.status_code}")
            print(f"   📊 Response preview: {str(data)[:100]}...")
            return True
        else:
            print(f"   ❌ Failed! Status: {response.status_code}")
            print(f"   📝 Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Request failed: {e}")
        return False
    except json.JSONDecodeError as e:
        print(f"   ❌ JSON decode failed: {e}")
        return False
    except Exception as e:
        print(f"   ❌ Unexpected error: {e}")
        return False


def main():
    """Run all API tests."""
    base_url = "http://localhost:8000"
    symbol = "AAPL"  # Test with Apple stock
    
    print("🚀 TradingAgents API Test Suite")
    print("=" * 50)
    
    # Test endpoints
    endpoints = [
        (f"{base_url}/api/health", "Health Check"),
        (f"{base_url}/api/stock/{symbol}/chart", "Stock Chart Data"),
        (f"{base_url}/api/stock/{symbol}/technical-indicators", "Technical Indicators"),
        (f"{base_url}/api/stock/{symbol}/trade-recommendations", "Trade Recommendations"),
    ]
    
    results = []
    
    for url, name in endpoints:
        success = test_endpoint(url, name)
        results.append((name, success))
    
    # Summary
    print("\n" + "=" * 50)
    print("📋 Test Results Summary:")
    print("=" * 50)
    
    passed = 0
    total = len(results)
    
    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"   {status} {name}")
        if success:
            passed += 1
    
    print(f"\n🎯 Overall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! API is working correctly.")
    else:
        print("⚠️  Some tests failed. Check the API server and configuration.")
        print("\n💡 Troubleshooting tips:")
        print("   1. Make sure the API server is running: python api/main.py")
        print("   2. Check if all dependencies are installed: pip install -r requirements.txt")
        print("   3. Verify your TradingAgents configuration and API keys")
        print("   4. Check internet connection for real-time data sources")
    
    return passed == total


if __name__ == "__main__":
    main() 