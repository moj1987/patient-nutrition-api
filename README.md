# Patient Nutrition API

Rails API for managing patient meals with dietary restrictions and nutrition tracking.

## Setup

```bash
bundle install
rails db:create db:migrate
rails db:seed
rails s
```

## Features

- Patient management with dietary restrictions
- Food item database with nutrition data
- Meal planning and nutrition calculation
- Dietary restriction validation
- JSONB for array data

## Quick Start

```bash
# Create patient
curl -X POST http://localhost:3000/patients \
  -H "Content-Type: application/json" \
  -d '{"name":"John","age":45,"room_number":"101","dietary_restrictions":["gluten"],"status":"active"}'

# Add food to meal
curl -X POST http://localhost:3000/meals/1/meal_food_items \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":1,"portion_size":1.0}}'
```

## Testing

```bash
bundle exec rspec
```

## API Documentation

See [API_DOCS.md](./API_DOCS.md) for detailed endpoints and data models.
