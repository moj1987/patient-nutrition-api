## Context
The patient nutrition API currently has no authentication mechanism, exposing all endpoints publicly. Email OTP authentication provides secure access without requiring password storage or management, ideal for API-only applications.

## Goals / Non-Goals
- Goals: Secure API endpoints, implement email-based authentication, provide short-lived JWT tokens
- Non-Goals: Password management, role-based permissions, OAuth integration, long-lived sessions

## Decisions
- Decision: Use email + OTP authentication
  - Why: No password storage, secure, simple for API users
- Decision: Use Redis for OTP code storage
  - Why: Fast expiration, automatic cleanup, scalable
- Decision: Issue short-lived JWT tokens (5 minutes)
  - Why: Stateless, reduces token theft impact, forces fresh authentication
- Decision: Auto-create user accounts on first successful auth
  - Why: Simplifies user management, no registration required
- Decision: Use ActionMailer for email delivery
  - Why: Rails standard, configurable for development/production

## Risks / Trade-offs
- Risk: Email delivery delays → Mitigation: Use reliable email service, provide clear error messages
- Risk: OTP brute force → Mitigation: Rate limiting, account lockout after failures
- Risk: Token interception → Mitigation: Short expiration, HTTPS only
- Trade-off: Convenience vs security → Chose balanced approach with OTP + short tokens

## Migration Plan
1. Add User model (email only)
2. Implement OTP generation and Redis storage
3. Create authentication endpoints
4. Add JWT token service
5. Implement authentication middleware
6. Protect existing routes
7. Set up email delivery
8. Update tests and documentation

## Open Questions
- Email service provider (SendGrid, AWS SES, SMTP)?
- OTP code length (6 digits default)?
- Rate limiting thresholds (5 requests per minute per email)?
- Development email handling (letter_opener vs real emails)?
