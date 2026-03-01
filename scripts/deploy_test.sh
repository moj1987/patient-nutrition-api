#!/bin/bash

echo "🔥 Testing Environment Variable Loading..."

# Load .env and export as environment variables
set -a
source .env
set +a

echo "✅ Environment variables loaded:"
echo "SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:10}..."
echo "REDIS_URL: ${REDIS_URL:0:20}..."
echo "DATABASE_URL: ${DATABASE_URL:0:20}..."
echo "LAMBDA_ACCESS_KEY_ID: ${LAMBDA_ACCESS_KEY_ID:0:10}..."
echo "LAMBDA_SECRET_ACCESS_KEY: ${LAMBDA_SECRET_ACCESS_KEY:0:10}..."
echo "LAMBDA_REGION: $LAMBDA_REGION"

echo ""
echo "🔥 Building Docker image..."
docker build -f Dockerfile.sidekiq -t meal-planner-sidekiq .

echo ""
echo "🔥 Starting container with Render-like environment..."
docker run -d --name sidekiq-deploy-test \
  -e REDIS_URL="$REDIS_URL" \
  -e DATABASE_URL="$DATABASE_URL" \
  -e LAMBDA_ACCESS_KEY_ID="$LAMBDA_ACCESS_KEY_ID" \
  -e LAMBDA_SECRET_ACCESS_KEY="$LAMBDA_SECRET_ACCESS_KEY" \
  -e LAMBDA_REGION="$LAMBDA_REGION" \
  -e SECRET_KEY_BASE="$SECRET_KEY_BASE" \
  -e RAILS_ENV=production \
  meal-planner-sidekiq

echo ""
echo "✅ Container started! Check logs with:"
echo "docker logs -f sidekiq-deploy-test"
