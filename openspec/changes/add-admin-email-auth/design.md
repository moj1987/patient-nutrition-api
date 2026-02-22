## Context
The current OTP authentication system requires Redis for OTP storage and email services for OTP delivery. This creates deployment complexity and makes the application incompatible with free hosting tiers like Render.com that don't include these services. The system needs a simpler authentication approach that maintains security while reducing dependencies.

## Goals / Non-Goals
- Goals: 
  - Eliminate Redis dependency for authentication
  - Eliminate email service dependency for OTP delivery
  - Maintain security through email-based access control
  - Enable deployment on free hosting tiers
  - Simplify operational complexity
- Non-Goals:
  - Support for user registration/self-service access
  - Multi-factor authentication beyond email validation
  - Role-based access control beyond admin/user distinction

## Decisions
- Decision: Use environment variable ALLOWED_EMAILS for email whitelist
  - Why: Simple, secure, no database storage required, easy to configure
  - Alternatives considered: Database-stored whitelist (adds complexity), LDAP integration (overkill)
- Decision: Remove OTP generation and verification entirely
  - Why: Email whitelist provides sufficient security for admin access
  - Alternatives considered: Keep OTP as optional 2FA (adds complexity without clear benefit)
- Decision: Generate short-lived JWT tokens (5 minutes)
  - Why: Balance between security and usability, reduces token exposure risk
  - Alternatives considered: Longer expiry (less secure), shorter expiry (poor UX)
- Decision: Auto-create user records on first successful authentication
  - Why: Simplifies user management, maintains existing User model structure
  - Alternatives considered: Manual user creation (more operational overhead)

## Risks / Trade-offs
- Risk: Email addresses in environment variables may be exposed in logs
  - Mitigation: Use proper environment variable handling, avoid logging auth configs
- Risk: Compromised email account grants access to system
  - Mitigation: Use strong email security, monitor for suspicious activity
- Trade-off: Reduced security compared to OTP (no second factor)
  - Acceptable for admin-only access with strong email security
- Trade-off: No self-service registration
  - Acceptable for admin/clinical use case where access is controlled

## Migration Plan
1. Deploy new authentication system alongside existing OTP system
2. Update ALLOWED_EMAILS environment variable with admin emails
3. Test new authentication endpoints
4. Switch routes to use new authentication endpoints
5. Remove OTP-related code and dependencies
6. Update documentation and deployment guides
7. Rollback: Revert to OTP endpoints if issues arise

## Open Questions
- Should we keep the existing OTP endpoints for a transition period?
- Do we need to migrate existing user records or can they be auto-created?
- Should we add rate limiting to prevent brute force email attempts?
