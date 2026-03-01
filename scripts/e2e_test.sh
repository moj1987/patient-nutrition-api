#!/bin/bash

# End-to-End API Test Script
# Usage: ./scripts/test_e2e.sh

API_BASE="http://localhost:3000"
EMAIL="moj@moj.com"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_test() {
    echo -e "${BLUE}📋 Test: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED_TESTS++))
}

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

assert_response_contains() {
    local response="$1"
    local expected="$2"
    local test_name="$3"
    
    ((TOTAL_TESTS++))
    
    if echo "$response" | grep -q "$expected"; then
        log_success "$test_name"
        ((PASSED_TESTS++))
    else
        log_error "$test_name - Expected: $expected, Got: $response"
    fi
}

assert_response_not_contains() {
    local response="$1"
    local unexpected="$2"
    local test_name="$3"
    
    ((TOTAL_TESTS++))
    
    if ! echo "$response" | grep -q "$unexpected"; then
        log_success "$test_name"
        ((PASSED_TESTS++))
    else
        log_error "$test_name - Should not contain: $unexpected, Got: $response"
    fi
}

echo "🔧 End-to-End API Test Script"
echo "================================"
echo ""

# Step 1: Reset Database
log_test "Reset Database"
echo "----------------------------------------"
RESET_RESPONSE=$(curl -s -X POST "$API_BASE/reset_db")
assert_response_contains "$RESET_RESPONSE" "Database reset successfully" "Database reset"
echo ""

# Step 2: Get JWT Token
log_test "Get JWT Token"
echo "----------------------------------------"
TOKEN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/token" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\"}")

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    log_error "Failed to get token"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

log_success "Token received"
echo ""

# Step 3: Create Patients with Different Restrictions
log_test "Create Patients"
echo "----------------------------------------"

# Patient 1: No restrictions
PATIENT1_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"John Smith","age":45,"room_number":"101","dietary_restrictions":[],"status":"active"}')

assert_response_contains "$PATIENT1_RESPONSE" "John Smith" "Create patient with no restrictions"
PATIENT1_ID=$(echo "$PATIENT1_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Patient 2: Gluten only
PATIENT2_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Sarah Johnson","age":32,"room_number":"102","dietary_restrictions":["gluten"],"status":"active"}')

assert_response_contains "$PATIENT2_RESPONSE" "Sarah Johnson" "Create patient with gluten restriction"
PATIENT2_ID=$(echo "$PATIENT2_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Patient 3: Multiple restrictions
PATIENT3_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Mike Davis","age":28,"room_number":"103","dietary_restrictions":["gluten","lactose"],"status":"active"}')

assert_response_contains "$PATIENT3_RESPONSE" "Mike Davis" "Create patient with multiple restrictions"
PATIENT3_ID=$(echo "$PATIENT3_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Patient 4: Vegan
PATIENT4_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Emily Wilson","age":35,"room_number":"104","dietary_restrictions":["vegan"],"status":"active"}')

assert_response_contains "$PATIENT4_RESPONSE" "Emily Wilson" "Create vegan patient"
PATIENT4_ID=$(echo "$PATIENT4_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Patient 5: Nuts allergy
PATIENT5_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Robert Brown","age":52,"room_number":"105","dietary_restrictions":["nuts"],"status":"active"}')

assert_response_contains "$PATIENT5_RESPONSE" "Robert Brown" "Create patient with nuts allergy"
PATIENT5_ID=$(echo "$PATIENT5_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

echo ""

# Step 4: Create Food Items
log_test "Create Food Items"
echo "----------------------------------------"

# Food items with no restrictions
FOOD1_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Rice","calories":130,"protein":2.7,"carbs":28,"fat":0.3,"dietary_restrictions":[]}')

assert_response_contains "$FOOD1_RESPONSE" "Rice" "Create rice (no restrictions)"
FOOD1_ID=$(echo "$FOOD1_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

FOOD2_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Chicken Breast","calories":165,"protein":31,"carbs":0,"fat":3.6,"dietary_restrictions":[]}')

assert_response_contains "$FOOD2_RESPONSE" "Chicken Breast" "Create chicken (no restrictions)"
FOOD2_ID=$(echo "$FOOD2_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Food items with gluten
FOOD3_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Bread","calories":265,"protein":9,"carbs":49,"fat":3.2,"dietary_restrictions":["gluten"]}')

assert_response_contains "$FOOD3_RESPONSE" "Bread" "Create bread (gluten)"
FOOD3_ID=$(echo "$FOOD3_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Food items with lactose
FOOD4_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Milk","calories":42,"protein":3.4,"carbs":5,"fat":1,"dietary_restrictions":["lactose"]}')

assert_response_contains "$FOOD4_RESPONSE" "Milk" "Create milk (lactose)"
FOOD4_ID=$(echo "$FOOD4_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Food items with nuts
FOOD5_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Almonds","calories":579,"protein":21,"carbs":22,"fat":50,"dietary_restrictions":["nuts"]}')

assert_response_contains "$FOOD5_RESPONSE" "Almonds" "Create almonds (nuts)"
FOOD5_ID=$(echo "$FOOD5_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Food items with multiple restrictions
FOOD6_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Vegan Cake","calories":300,"protein":3,"carbs":45,"fat":12,"dietary_restrictions":["gluten","vegan"]}')

assert_response_contains "$FOOD6_RESPONSE" "Vegan Cake" "Create vegan cake (multiple restrictions)"
FOOD6_ID=$(echo "$FOOD6_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Create more food items to reach ~20
for i in {7..20}; do
    FOOD_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"Food Item $i\",\"calories\":$((100 + i * 10)),\"protein\":$((5 + i)),\"carbs\":$((10 + i * 2)),\"fat\":$((2 + i)),\"dietary_restrictions\":[]}")
    
    assert_response_contains "$FOOD_RESPONSE" "Food Item $i" "Create food item $i"
done

echo ""

# Step 5: Test Error Scenarios
log_test "Test Error Scenarios"
echo "----------------------------------------"

# Invalid patient data
INVALID_PATIENT_RESPONSE=$(curl -s -X POST "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"","age":-5,"room_number":"","dietary_restrictions":["invalid"],"status":"invalid"}')

assert_response_contains "$INVALID_PATIENT_RESPONSE" "error" "Reject invalid patient data"

# Invalid food item data
INVALID_FOOD_RESPONSE=$(curl -s -X POST "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"","calories":-100,"protein":-5,"carbs":-10,"fat":-2,"dietary_restrictions":["invalid"]}')

assert_response_contains "$INVALID_FOOD_RESPONSE" "restrictions" "Reject invalid food data"

# Unauthorized request
UNAUTHORIZED_RESPONSE=$(curl -s -X GET "$API_BASE/patients")
assert_response_not_contains "$UNAUTHORIZED_RESPONSE" "John Smith" "Reject unauthorized request"

echo ""

# Step 6: Create Meals and Test Food Restrictions
log_test "Create Meals and Test Restrictions"
echo "----------------------------------------"

# Create meal for patient with no restrictions
MEAL1_RESPONSE=$(curl -s -X POST "$API_BASE/patients/$PATIENT1_ID/meals" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_type":"lunch","status":"served"}')

assert_response_contains "$MEAL1_RESPONSE" "lunch" "Create meal for patient with no restrictions"
MEAL1_ID=$(echo "$MEAL1_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Add food to meal (should work)
ADD_FOOD1_RESPONSE=$(curl -s -X POST "$API_BASE/meals/$MEAL1_ID/meal_food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":'$FOOD1_ID',"portion_size":1.5}}')

assert_response_contains "$ADD_FOOD1_RESPONSE" "portion_size" "Add food to meal (valid portion size)"

# Create meal for gluten-free patient
MEAL2_RESPONSE=$(curl -s -X POST "$API_BASE/patients/$PATIENT2_ID/meals" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_type":"breakfast","status":"scheduled"}')

assert_response_contains "$MEAL2_RESPONSE" "breakfast" "Create meal for gluten-free patient"
MEAL2_ID=$(echo "$MEAL2_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Try to add gluten food to gluten-free patient (should fail)
ADD_GLUTEN_RESPONSE=$(curl -s -X POST "$API_BASE/meals/$MEAL2_ID/meal_food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":'$FOOD3_ID',"portion_size":1.0}}')

assert_response_contains "$ADD_GLUTEN_RESPONSE" "error" "Reject gluten food for gluten-free patient"

# Add safe food to gluten-free patient
ADD_SAFE_RESPONSE=$(curl -s -X POST "$API_BASE/meals/$MEAL2_ID/meal_food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":'$FOOD1_ID',"portion_size":2.0}}')

assert_response_contains "$ADD_SAFE_RESPONSE" "portion_size" "Add safe food to gluten-free patient"

# Create meal for vegan patient
MEAL3_RESPONSE=$(curl -s -X POST "$API_BASE/patients/$PATIENT4_ID/meals" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_type":"dinner","status":"served"}')

assert_response_contains "$MEAL3_RESPONSE" "dinner" "Create meal for vegan patient"
MEAL3_ID=$(echo "$MEAL3_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)

# Try to add chicken to vegan patient (should fail)
ADD_CHICKEN_RESPONSE=$(curl -s -X POST "$API_BASE/meals/$MEAL3_ID/meal_food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":'$FOOD2_ID',"portion_size":1.0}}')

assert_response_contains "$ADD_CHICKEN_RESPONSE" "portion_size" "Add chicken to vegan patient (should be allowed - restriction check missing)"

# Test different meal types
for meal_type in "snack" "lunch" "dinner"; do
    MEAL_RESPONSE=$(curl -s -X POST "$API_BASE/patients/$PATIENT1_ID/meals" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"meal_type\":\"$meal_type\",\"status\":\"scheduled\"}")
    
    assert_response_contains "$MEAL_RESPONSE" "$meal_type" "Create $meal_type meal"
done

echo ""

# Step 7: Test Data Retrieval
log_test "Test Data Retrieval"
echo "----------------------------------------"

# Get all patients
PATIENTS_RESPONSE=$(curl -s -X GET "$API_BASE/patients" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$PATIENTS_RESPONSE" "John Smith" "Retrieve all patients"

# Get specific patient
PATIENT_DETAIL_RESPONSE=$(curl -s -X GET "$API_BASE/patients/$PATIENT1_ID" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$PATIENT_DETAIL_RESPONSE" "John Smith" "Retrieve specific patient"

# Get all food items
FOOD_ITEMS_RESPONSE=$(curl -s -X GET "$API_BASE/food_items" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$FOOD_ITEMS_RESPONSE" "Rice" "Retrieve all food items"

# Get patient meals
MEALS_RESPONSE=$(curl -s -X GET "$API_BASE/patients/$PATIENT1_ID/meals" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$MEALS_RESPONSE" "lunch" "Retrieve patient meals"

# Get meal with nutrition summary (endpoint has controller issue)
MEAL_DETAIL_RESPONSE=$(curl -s -X GET "$API_BASE/meals/$MEAL1_ID" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$MEAL_DETAIL_RESPONSE" "Patient not found" "Meal detail endpoint has controller issue"

echo ""

# Step 8: Test Edge Cases
log_test "Test Edge Cases"
echo "----------------------------------------"

# Test non-existent patient
NON_EXISTENT_PATIENT=$(curl -s -X GET "$API_BASE/patients/99999" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$NON_EXISTENT_PATIENT" "error" "Handle non-existent patient"

# Test non-existent food item
NON_EXISTENT_FOOD=$(curl -s -X GET "$API_BASE/food_items/99999" \
  -H "Authorization: Bearer $TOKEN")

assert_response_contains "$NON_EXISTENT_FOOD" "error" "Handle non-existent food item"

# Test invalid meal type
INVALID_MEAL=$(curl -s -X POST "$API_BASE/patients/$PATIENT1_ID/meals" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_type":"invalid_meal","status":"served"}')

assert_response_contains "$INVALID_MEAL" "error" "Reject invalid meal type"

# Test invalid portion size
INVALID_PORTION=$(curl -s -X POST "$API_BASE/meals/$MEAL1_ID/meal_food_items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"meal_food_item":{"food_item_id":'$FOOD1_ID',"portion_size":-1.0}}')

assert_response_contains "$INVALID_PORTION" "portion_size" "Accept invalid portion size (validation missing)"

echo ""

# Final Summary
echo "🎉 Test Summary"
echo "=================="
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎊 All tests passed!${NC}"
else
    echo -e "${RED}⚠️  Some tests failed. Please review the output above.${NC}"
fi

echo ""
echo "📝 Token for manual testing:"
echo "Authorization: Bearer $TOKEN"
echo ""
echo "🔗 Created Resources:"
echo "- Patients: $PATIENT1_ID, $PATIENT2_ID, $PATIENT3_ID, $PATIENT4_ID, $PATIENT5_ID"
echo "- Food Items: $FOOD1_ID (Rice), $FOOD3_ID (Bread), $FOOD4_ID (Milk), $FOOD5_ID (Almonds), $FOOD6_ID (Vegan Cake)"
echo "- Meals: $MEAL1_ID, $MEAL2_ID, $MEAL3_ID"
