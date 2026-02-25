# Patient Nutrition API

Rails API with microservices architecture for patient meal planning using Sidekiq, AWS Lambda, and Supabase.

## Setup

```bash
bundle install
rails db:create db:migrate
rails db:seed
redis-server
bundle exec sidekiq
rails s
```

## Features

- Patient management with dietary restrictions
- Food item database with nutrition data
- Meal planning and nutrition calculation
- Dietary restriction validation
- JWT authentication
- **Microservices Architecture**: Sidekiq + AWS Lambda + Supabase for meal plan generation

## Quick Start

```bash
# Generate meal plan (asynchronous)
curl -X POST http://localhost:3000/patients/1/meal_plans/generate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"period_days": 3, "target_calories": 2000, "target_protein": 50, "dietary_restrictions": ["gluten"]}'

# Response: {"message": "Meal plan generation started", "job_id": "abc123"}
```

## Testing

```bash
bundle exec rspec
```

## API Documentation

See [API_DOCS.md](./API_DOCS.md) for detailed endpoints and data models.
