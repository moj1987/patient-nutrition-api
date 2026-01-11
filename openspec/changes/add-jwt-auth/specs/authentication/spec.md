## ADDED Requirements
### Requirement: OTP Code Request
The system SHALL generate and email one-time password codes to users for authentication.

#### Scenario: Successful OTP request
- **WHEN** a user provides a valid email address
- **THEN** a 6-digit OTP code is generated and emailed
- **AND** the code expires after 5 minutes

#### Scenario: Invalid email format
- **WHEN** a user provides an invalid email format
- **THEN** the request is rejected with appropriate error message

### Requirement: Email OTP Authentication
The system SHALL authenticate users using email and OTP codes and issue short-lived JWT tokens.

#### Scenario: Successful OTP authentication
- **WHEN** a user provides valid email and OTP code
- **THEN** a short-lived JWT token is returned
- **AND** the token expires after 5 minutes
- **AND** the OTP code is consumed after use

#### Scenario: Invalid OTP code
- **WHEN** a user provides incorrect OTP code
- **THEN** authentication fails with error message

#### Scenario: Expired OTP code
- **WHEN** a user provides an expired OTP code
- **THEN** authentication fails with appropriate error message

### Requirement: Token Validation
The system SHALL validate JWT tokens for protected API endpoints.

#### Scenario: Valid token access
- **WHEN** a request includes a valid JWT token
- **THEN** the request is processed successfully
- **AND** user context is available to the controller

#### Scenario: Invalid token access
- **WHEN** a request includes an invalid or expired token
- **THEN** the request is rejected with 401 Unauthorized

#### Scenario: Missing token access
- **WHEN** a request to a protected endpoint lacks a token
- **THEN** the request is rejected with 401 Unauthorized

### Requirement: User Management
The system SHALL automatically create user accounts on first successful authentication.

#### Scenario: New user authentication
- **WHEN** a new email authenticates successfully for the first time
- **THEN** a user account is automatically created
- **AND** user ID is included in JWT token

#### Scenario: Returning user authentication
- **WHEN** an existing user authenticates successfully
- **THEN** their existing user account is used
- **AND** user ID is included in JWT token
