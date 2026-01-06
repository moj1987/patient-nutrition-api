# Patient Nutrition Tracker API - 1 Week Implementation Plan

## Context
- **You**: Kotlin mobile dev, completed Ruby basics (Ruby in 20 mins + classes)
- **Goal**: Interview-ready Ruby on Rails in 1 week
- **LLM**: Gemini in this project is a tutor. Must not give answers. Just help like a tutor.
- **Reality**: Can't build everything in spec - focus on solid MVP

---

## What to Build (Priority Order)

### MVP - Must Have
1. ✅ Patient CRUD (name, age, room, dietary restrictions, status)
2. ✅ FoodItem CRUD (nutrition data)
3. ✅ Meal management (nested under patients, associated with food items)
4. ✅ Model validations + associations
5. ✅ Basic tests (model + request specs)
6. ✅ Seed data + README

### Nice to Have (High Impact)
7. Nutrition calculation (sum calories/nutrients per meal)
8. Dietary restriction validation (custom validations)
9. Search/filtering (by name, dietary restrictions, dates)
10. Error handling (consistent JSON responses)

### Skip for Now
- Background jobs (Sidekiq)
- Caching (Redis)
- JWT authentication
- Deployment
- Advanced analytics

---

## Week Timeline

### Days 1-2: Rails Setup + Models
- [x] Install PostgreSQL
- [x] Initialize Rails API project (`rails new`)
- [x] Create migrations for 4 tables (patients, food_items, meals, meal_food_items)
- [x] Build models with associations (`has_many`, `belongs_to`, `has_many :through`)
- [x] Add validations (presence, length, format, enums)
- [x] Write model specs

**Rails Guides to Read:**
- Getting Started
- Active Record Basics
- Active Record Associations
- Active Record Validations

### Days 3-4: Controllers + Routes
- [x] Build PatientsController (index, show, create, update, destroy)
- [x] Build FoodItemsController (index, show, create)
- [x] Build MealsController (nested routes)
- [x] Strong parameters + error handling
- [x] Write request specs for endpoints

**Rails Guides to Read:**
- Action Controller Overview
- Routing
- API-only Applications

### Days 5-6: Testing + Business Logic
- [x] Set up RSpec + FactoryBot
- [x] Write comprehensive model tests
- [x] Write request specs (happy + error paths)
- [x] Add nutrition calculation method
- [x] Add dietary restriction validation
- [x] Test with Postman/curl

**Documentation to Read:**
- RSpec Rails guide
- FactoryBot getting started

### Day 7: Polish
- [x] Create seed data (realistic examples)
- [x] Write README (setup, endpoints, design decisions)
- [x] Test entire flow end-to-end
- [x] Fix bugs
- [ ] Optional: deploy to Heroku/Railway

---

## Key Concepts to Understand

### Database
- **Migrations**: Version control for schema
- **Associations**: `has_many :through` for meal_food_items join table
- **JSONB**: For dietary_restrictions array
- **Indexes**: On foreign keys, status, dates

### Rails Patterns
- **Convention over Configuration**: File/class naming matters
- **Strong Parameters**: Prevent mass assignment attacks
- **RESTful Routes**: Standard CRUD operations
- **Nested Routes**: `/patients/:patient_id/meals`

### Testing
- **Model specs**: Test validations, associations, business logic
- **Request specs**: Test HTTP endpoints, not controllers
- **Factories**: Clean test data with FactoryBot

---

## Database Schema (What to Build)

```
patients
├─ dietary_restrictions (JSONB)
├─ status (enum: active/discharged)
└─ has_many :meals

food_items
├─ nutrition data (calories, protein, carbs, etc.)
└─ has_many :meal_food_items

meals
├─ belongs_to :patient
├─ meal_type (enum: breakfast/lunch/dinner/snack)
├─ status (enum: scheduled/served/skipped)
└─ has_many :food_items through: :meal_food_items

meal_food_items (join table)
├─ belongs_to :meal
├─ belongs_to :food_item
└─ portion_size (decimal)
```

---

## Learning Resources

**Where to Find Answers:**
- guides.rubyonrails.org (your primary resource)
- api.rubyonrails.org (API reference)
- rspec.info (testing)

**Kotlin → Rails Parallels:**
- Models = Data classes with Room
- Controllers = Ktor/Spring endpoints
- Migrations = Room migrations
- RSpec = JUnit/Kotest
- ActiveRecord = Room DAO

**When Stuck:**
- Read error messages (Rails errors are descriptive)
- Use `rails console` to experiment
- Check Rails guides for specific topics

---

## Interview Talking Points

**Technical Decisions to Explain:**
- Why `has_many :through` for meal_food_items (many-to-many with extra data)
- Why JSONB for dietary_restrictions (flexibility, no extra table needed)
- Why API-only mode (modern architecture, separate frontend)
- Why soft delete for patients (healthcare data retention)

**Be Honest About:**
- "First Ruby project, focused on fundamentals over feature completeness"
- "Prioritized working code + tests over advanced features"
- "Given more time: background jobs, caching, authentication"

**Questions You Should Answer:**
- What's `save` vs `save!`?
- What are strong parameters protecting against?
- Why test validations if Rails enforces them?
- How do nested routes work?

---

## Success Criteria

**Minimum (Interview-Ready):**
- Working CRUD for patients, meals, food items
- Proper associations (can create meal with food items)
- Validations working (can't create invalid records)
- ~50% test coverage (key validations + main endpoints)
- Seed data demonstrating functionality
- README with setup instructions

**Stretch (Impressive):**
- Nutrition calculation working
- Dietary restriction validation
- Search/filtering
- 80%+ test coverage

---

## Next Actions

1. Install PostgreSQL
2. `rails new patient-nutrition-api --api --database=postgresql`
3. Start with Patient model (simplest)
4. Build incrementally, test as you go
5. Commit frequently with clear messages
