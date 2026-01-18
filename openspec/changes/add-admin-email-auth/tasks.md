## 1. Implementation
- [ ] 1.1 Create EmailWhitelistService for validating emails against ALLOWED_EMAILS
- [ ] 1.2 Update Auth::AuthenticationController to use email whitelist instead of OTP
- [ ] 1.3 Remove request-otp endpoint and replace with simple token request endpoint
- [ ] 1.4 Update JWT token generation to use 5-minute expiry
- [ ] 1.5 Update User model to auto-create users on successful authentication
- [ ] 1.6 Remove OtpService class and Redis dependency
- [ ] 1.7 Remove OtpMailer class and email templates
- [ ] 1.8 Update routes to use new authentication endpoints
- [ ] 1.9 Update environment configuration documentation

## 2. Testing
- [ ] 2.1 Write tests for EmailWhitelistService
- [ ] 2.2 Write tests for new authentication endpoints
- [ ] 2.3 Write tests for JWT token generation with 5-minute expiry
- [ ] 2.4 Write tests for user auto-creation functionality
- [ ] 2.5 Update existing authentication tests to use new flow
- [ ] 2.6 Test with missing ALLOWED_EMAILS environment variable
- [ ] 2.7 Test with invalid email formats

## 3. Documentation
- [ ] 3.1 Update API documentation with new authentication flow
- [ ] 3.2 Update deployment guide with ALLOWED_EMAILS configuration
- [ ] 3.3 Document migration steps from OTP to email whitelist
- [ ] 3.4 Update README with simplified authentication requirements

## 4. Cleanup
- [ ] 4.1 Remove Redis gem from Gemfile if no longer needed
- [ ] 4.2 Remove Redis configuration files
- [ ] 4.3 Remove OTP-related test files
- [ ] 4.4 Remove any remaining OTP references in code comments
