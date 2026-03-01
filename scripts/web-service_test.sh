#!/bin/bash

echo "🔥 Testing Web Service (meal-planner-api)..."

# Load .env and export as environment variables
set -a
source .env
set +a

echo "✅ Environment variables loaded:"
echo "DATABASE_URL: ${DATABASE_URL:0:20}..."
echo "REDIS_URL: ${REDIS_URL:0:20}..."
echo "SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:10}..."

echo ""
echo "🔥 Building Web Service Docker image..."
docker build -f Dockerfile -t meal-planner-api .

echo ""
echo "🔥 Starting Web Service with Render-like environment..."
docker run -d --name meal-planner-api-test \
  -p 3000:3000 \
  -e DATABASE_URL="$DATABASE_URL" \
  -e REDIS_URL="$REDIS_URL" \
  -e SECRET_KEY_BASE="$SECRET_KEY_BASE" \
  -e RAILS_ENV=production \
  meal-planner-api

echo ""
echo "✅ Web Service started! Check logs with:"
echo "docker logs -f meal-planner-api-test"

echo ""
echo "🌐 Test API at: http://localhost:3000"
