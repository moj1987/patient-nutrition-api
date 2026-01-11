# Change: Add Email OTP Authentication

## Why
The API currently has no authentication mechanism, exposing all patient nutrition data without access controls. Email OTP authentication will secure the API using email verification without requiring password storage or management.

## What Changes
- Add email-based one-time password (OTP) authentication system
- Implement OTP code generation and email delivery
- Add short-lived JWT token issuance after OTP verification
- Add authentication middleware to protect API routes
- **BREAKING**: All existing endpoints will require authentication except health check and auth endpoints

## Impact
- Affected specs: New authentication capability
- Affected code: All controllers, routes, and application middleware
- New dependencies: jwt gem, redis gem (for OTP storage), email service
