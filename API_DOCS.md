# Patient Nutrition API

## Authentication

All endpoints (except auth) require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

### Auth
- `POST /auth/token` - Get JWT token

## Endpoints

### Patients
- `GET /patients` - List all patients
- `GET /patients/:id` - Get patient details
- `POST /patients` - Create patient
- `PATCH /patients/:id` - Update patient
- `DELETE /patients/:id` - Delete patient

### Food Items
- `GET /food_items` - List all food items
- `GET /food_items/:id` - Get food item details
- `POST /food_items` - Create food item

### Meals
- `GET /patients/:patient_id/meals` - List patient meals
- `POST /patients/:patient_id/meals` - Create meal
- `GET /meals/:id` - Get meal with nutrition summary

### Meal Food Items
- `POST /meals/:meal_id/meal_food_items` - Add food to meal

### Meal Plans
- `POST /patients/:patient_id/meal_plans/generate` - Generate meal plan via AWS Lambda

### Utilities
- `POST /reset_db` - Reset database (development only)

## Data Models

### Patient
```json
{
  "name": "string",
  "age": "integer",
  "room_number": "string",
  "dietary_restrictions": ["gluten", "lactose", "nuts", "vegetarian", "vegan"],
  "status": "active|discharged",
  "admition_date": "datetime"
}
```

### Food Item
```json
{
  "name": "string",
  "calories": "integer",
  "protein": "number",
  "carbs": "number",
  "fat": "number",
  "fiber": "number",
  "sugar": "number",
  "sodium": "number",
  "dietary_restrictions": ["gluten", "lactose", "nuts", "vegetarian", "vegan"]
}
```

### Meal
```json
{
  "meal_type": "breakfast|lunch|dinner|snack",
  "status": "served|scheduled|skipped",
  "scheduled_at": "datetime",
  "nutrition_summary": {
    "calories": 130.0,
    "protein": 3.0,
    "carbs": 28.0,
    "fat": 1.0
  }
}
```

## Key Features

- **Dietary Restriction Validation**: Prevents adding food that violates patient restrictions
- **Nutrition Calculation**: Automatic calculation of meal nutrition data
- **JWT Authentication**: Secure API access
- **AWS Lambda Integration**: Meal plan generation

## Example Usage

```bash
# Get auth token
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Create patient with restrictions
curl -X POST http://localhost:3000/patients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"John","age":45,"room_number":"101","dietary_restrictions":["gluten"],"status":"active"}'

# Add food to meal (will fail if violates restrictions)
curl -X POST http://localhost:3000/meals/1/meal_food_items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"meal_food_item":{"food_item_id":1,"portion_size":1.0}}'
```
