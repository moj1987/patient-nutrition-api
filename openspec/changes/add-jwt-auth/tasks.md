## 1. Implementation
- [ ] 1.1 Add JWT and Redis gems to Gemfile
- [ ] 1.2 Create User model with email only
- [ ] 1.3 Create authentication controller with OTP request and token endpoints
- [ ] 1.4 Implement OTP code generation and storage service (Redis)
- [ ] 1.5 Implement JWT token generation and validation service
- [ ] 1.6 Add authentication middleware to protect routes
- [ ] 1.7 Update routes to include auth endpoints and protect existing ones
- [ ] 1.8 Create database migration for users table
- [ ] 1.9 Set up email delivery for OTP codes
- [ ] 1.10 Write tests for OTP request and authentication endpoints
- [ ] 1.11 Write tests for authentication middleware
- [ ] 1.12 Update existing controller tests to handle authentication

## 2. Test Plan for JWT + Email OTP Flow

### 2.1 Authentication Endpoint Tests
- [ ] 2.1.1 Test OTP request endpoint (`POST /auth/request-otp`)
  - **Scenario**: Valid email format
    - **WHEN** POST to `/auth/request-otp` with valid email
    - **THEN** return 200 OK
    - **AND** OTP code is generated and stored in Redis
    - **AND** email delivery is triggered
  - **Scenario**: Invalid email format
    - **WHEN** POST to `/auth/request-otp` with invalid email
    - **THEN** return 422 Unprocessable Entity
    - **AND** error message indicates invalid email format
  - **Scenario**: Missing email parameter
    - **WHEN** POST to `/auth/request-otp` without email
    - **THEN** return 400 Bad Request
    - **AND** error message indicates missing required field

- [ ] 2.1.2 Test OTP verification endpoint (`POST /auth/verify-otp`)
  - **Scenario**: Valid OTP verification
    - **WHEN** POST to `/auth/verify-otp` with valid email and OTP
    - **THEN** return 200 OK
    - **AND** JWT token is included in response
    - **AND** token expires after 5 minutes
    - **AND** OTP code is consumed/marked as used
  - **Scenario**: Invalid OTP code
    - **WHEN** POST to `/auth/verify-otp` with incorrect OTP
    - **THEN** return 401 Unauthorized
    - **AND** error message indicates invalid OTP
  - **Scenario**: Expired OTP code
    - **WHEN** POST to `/auth/verify-otp` with expired OTP
    - **THEN** return 401 Unauthorized
    - **AND** error message indicates expired OTP
  - **Scenario**: Missing parameters
    - **WHEN** POST to `/auth/verify-otp` without email or OTP
    - **THEN** return 400 Bad Request
    - **AND** error message indicates missing required fields

### 2.2 User Management Tests
- [ ] 2.2.1 Test new user creation
  - **Scenario**: First-time authentication
    - **WHEN** new email successfully authenticates
    - **THEN** user account is automatically created in database
    - **AND** user ID is included in JWT token payload
    - **AND** user email is stored correctly

- [ ] 2.2.2 Test returning user authentication
  - **Scenario**: Existing user authentication
    - **WHEN** existing email successfully authenticates
    - **THEN** existing user account is used
    - **AND** user ID is included in JWT token payload
    - **AND** no duplicate user is created

### 2.3 Token Validation Tests
- [ ] 2.3.1 Test authentication middleware
  - **Scenario**: Valid token access to protected endpoint
    - **WHEN** request includes valid JWT token in Authorization header
    - **THEN** request is processed successfully
    - **AND** user context is available to controller
    - **AND** current_user helper returns correct user
  - **Scenario**: Invalid token access
    - **WHEN** request includes malformed JWT token
    - **THEN** return 401 Unauthorized
    - **AND** error message indicates invalid token
  - **Scenario**: Expired token access
    - **WHEN** request includes expired JWT token
    - **THEN** return 401 Unauthorized
    - **AND** error message indicates expired token
  - **Scenario**: Missing token access
    - **WHEN** request to protected endpoint lacks Authorization header
    - **THEN** return 401 Unauthorized
    - **AND** error message indicates authentication required

### 2.4 Integration Tests with Existing Endpoints
- [ ] 2.4.1 Test protected patient endpoints
  - **Scenario**: Authenticated access to patients
    - **WHEN** GET `/patients` with valid JWT token
    - **THEN** return patient data successfully
  - **Scenario**: Unauthenticated access to patients
    - **WHEN** GET `/patients` without token
    - **THEN** return 401 Unauthorized

- [ ] 2.4.2 Test protected food item endpoints
  - **Scenario**: Authenticated access to food items
    - **WHEN** GET `/food_items` with valid JWT token
    - **THEN** return food items successfully
  - **Scenario**: Unauthenticated access to food items
    - **WHEN** GET `/food_items` without token
    - **THEN** return 401 Unauthorized

- [ ] 2.4.3 Test protected meal endpoints
  - **Scenario**: Authenticated access to meals
    - **WHEN** GET `/meals` with valid JWT token
    - **THEN** return meals successfully
  - **Scenario**: Unauthenticated access to meals
    - **WHEN** GET `/meals` without token
    - **THEN** return 401 Unauthorized

### 2.5 Security Tests
- [ ] 2.5.1 Test OTP security measures
  - **Scenario**: OTP code uniqueness
    - **WHEN** multiple OTP requests for same email
    - **THEN** each OTP is unique
    - **AND** previous OTP codes are invalidated
  - **Scenario**: OTP rate limiting
    - **WHEN** excessive OTP requests from same email/IP
    - **THEN** rate limiting is enforced
    - **AND** appropriate error response is returned

- [ ] 2.5.2 Test JWT token security
  - **Scenario**: Token tampering
    - **WHEN** JWT token payload is modified
    - **THEN** token validation fails
    - **AND** request is rejected with 401
  - **Scenario**: Token replay protection
    - **WHEN** same JWT token is used after logout/refresh
    - **THEN** appropriate security measures are enforced

### 2.6 Performance and Load Tests
- [ ] 2.6.1 Test OTP generation performance
  - **Scenario**: Concurrent OTP requests
    - **WHEN** multiple users request OTPs simultaneously
    - **THEN** system handles load without degradation
    - **AND** all OTPs are generated correctly

- [ ] 2.6.2 Test token validation performance
  - **Scenario**: High-volume authenticated requests
    - **WHEN** many requests with valid JWT tokens
    - **THEN** token validation remains efficient
    - **AND** response times stay within acceptable limits

### 2.7 Edge Case Tests
- [ ] 2.7.1 Test email edge cases
  - **Scenario**: Email with special characters
  - **Scenario**: Very long email addresses
  - **Scenario**: Email case sensitivity handling

- [ ] 2.7.2 Test OTP edge cases
  - **Scenario**: OTP with leading zeros
  - **Scenario**: Multiple OTP attempts with same code
  - **Scenario**: OTP request immediately after previous request

- [ ] 2.7.3 Test JWT edge cases
  - **Scenario**: Token with unusual user data
  - **Scenario**: Token generation edge cases
  - **Scenario**: Token validation with malformed headers

### 2.8 Test Data Management
- [ ] 2.8.1 Set up test fixtures for authentication
  - Create test user factories
  - Set up OTP test data helpers
  - Configure JWT test environment

- [ ] 2.8.2 Test database cleanup
  - Ensure OTP Redis cleanup after tests
  - Verify user test data isolation
  - Test transaction rollback scenarios

### 2.9 Mock and Stub Strategy
- [ ] 2.9.1 Email service mocking
  - Mock email delivery for OTP tests
  - Verify email content without actual sending
  - Test email failure scenarios

- [ ] 2.9.2 Redis service mocking
  - Mock Redis for OTP storage tests
  - Test Redis failure scenarios
  - Verify OTP expiration logic

- [ ] 2.9.3 Time-based testing
  - Mock time for OTP expiration tests
  - Test JWT token expiration scenarios
  - Verify time-sensitive security measures
