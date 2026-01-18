## ADDED Requirements
### Requirement: Email Whitelist Authentication
The system SHALL authenticate users using an email whitelist approach without requiring OTP verification.

#### Scenario: Successful authentication with whitelisted email
- **WHEN** a user provides a whitelisted email address
- **THEN** the system SHALL return a JWT token valid for 5 minutes
- **AND** the system SHALL auto-create a user record if one doesn't exist

#### Scenario: Authentication attempt with non-whitelisted email
- **WHEN** a user provides an email not in the ALLOWED_EMAILS environment variable
- **THEN** the system SHALL return 401 unauthorized response
- **AND** no JWT token SHALL be issued

#### Scenario: Authentication attempt with invalid email format
- **WHEN** a user provides an invalid email format
- **THEN** the system SHALL return 422 unprocessable content response
- **AND** the system SHALL include validation error details

#### Scenario: Missing ALLOWED_EMAILS environment variable
- **WHEN** the ALLOWED_EMAILS environment variable is not configured
- **THEN** the system SHALL return 500 internal server error
- **AND** the system SHALL log the configuration issue

## REMOVED Requirements
### Requirement: OTP-Based Authentication
**Reason**: Replaced with email whitelist approach to eliminate Redis and email service dependencies
**Migration**: Existing OTP endpoints will be removed and replaced with simplified token request endpoint

#### Scenario: OTP request and verification
- **WHEN** a user requests an OTP for their email
- **THEN** the system SHALL generate a 6-digit code
- **AND** the system SHALL store the OTP in Redis with 5-minute expiry
- **AND** the system SHALL send the OTP via email
- **WHEN** the user provides the correct OTP
- **THEN** the system SHALL issue a JWT token

## MODIFIED Requirements
### Requirement: JWT Token Generation
The system SHALL generate JWT tokens with 5-minute expiry for authenticated users.

#### Scenario: Token generation for whitelisted email
- **WHEN** a whitelisted email is successfully authenticated
- **THEN** the system SHALL generate a JWT token with user ID
- **AND** the token SHALL expire after 5 minutes
- **AND** the token SHALL be valid for accessing protected endpoints

#### Scenario: User auto-creation on authentication
- **WHEN** a whitelisted email authenticates for the first time
- **THEN** the system SHALL create a new user record
- **AND** the user record SHALL contain the authenticated email
- **AND** the system SHALL use the new user ID for JWT token generation
