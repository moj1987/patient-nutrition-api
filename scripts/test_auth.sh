#!/bin/bash

# JWT Authentication Test Script
# Usage: ./scripts/test_auth.sh

API_BASE="http://localhost:3000"
EMAIL="moj@moj.com"

echo "🔐 JWT Authentication Test Script"
echo "================================"

# Step 1: Get JWT Token
echo ""
echo "📧 Step 1: Getting JWT token for $EMAIL"
echo "----------------------------------------"

TOKEN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/token" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\"}")

echo "Response: $TOKEN_RESPONSE"

# Extract token from response
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token"
  echo "Response: $TOKEN_RESPONSE"
  exit 1
fi

echo "✅ Token received: ${TOKEN:0:20}..."

# Step 2: Test Protected Endpoint
echo ""
echo "🔒 Step 2: Testing protected endpoint with token"
echo "------------------------------------------------"

PROTECTED_RESPONSE=$(curl -s -X GET "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "Response: $PROTECTED_RESPONSE"

# Step 3: Test Invalid Token
echo ""
echo "❌ Step 3: Testing with invalid token"
echo "-------------------------------------"

INVALID_RESPONSE=$(curl -s -X GET "$API_BASE/patients" \
  -H "Authorization: Bearer invalid_token" \
  -H "Content-Type: application/json")

echo "Response: $INVALID_RESPONSE"

# Step 4: Test No Token
echo ""
echo "🚫 Step 4: Testing without token"
echo "--------------------------------"

NO_TOKEN_RESPONSE=$(curl -s -X GET "$API_BASE/patients" \
  -H "Content-Type: application/json")

echo "Response: $NO_TOKEN_RESPONSE"

echo ""
echo "🎉 Test completed!"
echo ""
echo "📝 Token for manual testing:"
echo "Authorization: Bearer $TOKEN"
