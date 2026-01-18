# Change: Add Admin Email Whitelist Authentication

## Why
The current OTP authentication system requires Redis for OTP storage and email services for OTP delivery, making it incompatible with free hosting tiers like Render.com and adding operational complexity. An email whitelist approach eliminates these dependencies while maintaining security through email-based access control.

## What Changes
- Replace OTP-based authentication with email whitelist validation
- Use ALLOWED_EMAILS environment variable containing comma-separated emails
- Remove Redis dependency and OTP generation/verification logic
- Remove email service dependency for OTP delivery
- Generate short-lived JWT tokens (5 minutes) for authorized emails
- Auto-create user records on first successful authentication
- **BREAKING**: All existing endpoints will require authentication except health check and auth endpoints

## Impact
- Affected specs: authentication capability (replacing OTP approach)
- Affected code: Auth::AuthenticationController, OtpService, OtpMailer, User model
- Removed dependencies: Redis (for OTP storage), email service (for OTP delivery)
- Simplified deployment: Compatible with free hosting tiers
