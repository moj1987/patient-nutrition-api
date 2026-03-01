#!/bin/bash

echo "🚀 Testing Full Render.com Setup Locally..."
echo "This tests BOTH meal-planner-api and meal-planner-worker services"

# Load .env and export as environment variables
set -a
source .env
set +a

echo "✅ Environment variables loaded:"
echo "DATABASE_URL: ${DATABASE_URL:0:20}..."
echo "REDIS_URL: ${REDIS_URL:0:20}..."
echo "SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:10}..."
echo "ALLOWED_EMAILS: ${ALLOWED_EMAILS:0:30}..."

echo ""
echo "🔥 Building Web Service Docker image..."
docker build -f Dockerfile -t meal-planner-api .

echo ""
echo "🔥 Building Worker Service Docker image..."
docker build -f Dockerfile.sidekiq -t meal-planner-worker .

echo ""
echo "🔥 Starting Web Service (meal-planner-api)..."
docker run -d --name meal-planner-api-local \
  -p 3000:3000 \
  -e DATABASE_URL="$DATABASE_URL" \
  -e REDIS_URL="$REDIS_URL" \
  -e SECRET_KEY_BASE="$SECRET_KEY_BASE" \
  -e ALLOWED_EMAILS="$ALLOWED_EMAILS" \
  -e RAILS_ENV=production \
  meal-planner-api

echo ""
echo "🔥 Starting Worker Service (meal-planner-worker)..."
docker run -d --name meal-planner-worker-local \
  -e DATABASE_URL="$DATABASE_URL" \
  -e REDIS_URL="$REDIS_URL" \
  -e SECRET_KEY_BASE="$SECRET_KEY_BASE" \
  -e LAMBDA_ACCESS_KEY_ID="$LAMBDA_ACCESS_KEY_ID" \
  -e LAMBDA_SECRET_ACCESS_KEY="$LAMBDA_SECRET_ACCESS_KEY" \
  -e LAMBDA_REGION="$LAMBDA_REGION" \
  -e RAILS_ENV=production \
  meal-planner-worker

echo ""
echo "✅ Both services started!"
echo ""
echo "📊 Check service status:"
echo "docker ps"
echo ""
echo "📋 Check Web Service logs:"
echo "docker logs -f meal-planner-api-local"
echo ""
echo "📋 Check Worker Service logs:"
echo "docker logs -f meal-planner-worker-local"
echo ""
echo "🌐 Test API at: http://localhost:3000"
echo ""
echo "🧪 Test meal plan generation:"
echo "curl -X POST http://localhost:3000/patients/1/meal_plans/generate \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer <token>' \\"
echo "  -d '{\"period_days\": 1, \"target_calories\": 2000}'"
