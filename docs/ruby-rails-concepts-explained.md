# Ruby/Rails Concepts Deep Dive

## 1. "In-Memory" Data & Redis

### What "In-Memory" Means
"In-memory" means data is stored in RAM (volatile) vs disk (persistent).

```ruby
# Redis is in-memory - fast but temporary
$redis.setex("otp:user@email.com", 300, "123456")
# Data disappears when: 300 seconds pass OR server restarts

# Database is on disk - slower but persistent
User.create(email: "user@email.com")  
# Data survives server restarts
```

### When Data Gets Wiped
- **Redis expiration**: After 300 seconds (5 minutes) automatically
- **Server restart**: All Redis data is lost (that's why we use short expiration)
- **Memory pressure**: Redis may evict old data if RAM is full

### Why This is Perfect for OTP
- **Security**: OTP codes should be temporary anyway
- **Performance**: RAM access is 100x faster than disk
- **Auto-cleanup**: No need for cleanup jobs

---

## 2. REDIS_URL Environment Variable

### Why a URL Format
Redis uses URL format for connection parameters:

```bash
# REDIS_URL formats
redis://localhost:6379                    # Basic
redis://:password@localhost:6379           # With password
redis://user:pass@host:port/db             # Full connection
rediss://localhost:6379                   # SSL connection
```

### Where REDIS_URL Comes From

```bash
# 1. Environment variables (.env file)
REDIS_URL=redis://localhost:6379

# 2. System environment
export REDIS_URL=redis://localhost:6379

# 3. Rails credentials (encrypted)
rails credentials:edit
redis:
  url: redis://localhost:6379

# 4. Default fallback in code
url: ENV['REDIS_URL'] || 'redis://localhost:6379'
```

### Why URL vs Separate Parameters
- **Single config**: One environment variable vs multiple
- **Standard format**: Redis client libraries expect URL format
- **Flexibility**: Easy to change connection type (SSL, auth, etc.)

---

## 3. Random Number Security

### Is `rand(100000..999999)` Secure Enough?

```ruby
# Basic random - NOT secure for crypto
code = rand(100000..999999)

# Better - cryptographically secure
code = SecureRandom.random_number(100000..999999).to_s

# Even better - predefined secure codes
code = SecureRandom.hex(3).upcase  # 6-char hex
```

### Security Analysis

```ruby
# ❌ Predictable patterns
rand(100000..999999)
# Can be guessed if attacker knows generation algorithm

# ✅ Cryptographically secure
SecureRandom.random_number(100000..999999)
# Uses OS entropy sources, unpredictable

# ✅ Best practice
require 'securerandom'
code = Array.new(6) { SecureRandom.random_number(10) }.join
# Each digit independently random
```

### Recommendation
Use `SecureRandom` for OTP codes:

```ruby
# Gemfile
gem 'securerandom'  # Actually built into Ruby stdlib

# app/services/otp_service.rb
require 'securerandom'

class OtpService
  def self.generate(email)
    code = SecureRandom.random_number(100000..999999).to_s
    $redis.setex("otp:#{email}", 300, code)
    code
  end
end
```

---

## 4. Global Variables ($redis) in Ruby

### How $redis Works Across Files

```ruby
# config/initializers/redis.rb
$redis = Redis.new(url: ENV['REDIS_URL'])
# $redis is now GLOBAL - available everywhere

# app/services/otp_service.rb
class OtpService
  def self.generate(email)
    # $redis is accessible here!
    $redis.setex("otp:#{email}", 300, code)
  end
end

# app/controllers/api/auth_controller.rb  
class Api::AuthController < ApplicationController
  def token
    # $redis is also accessible here!
    stored_code = $redis.get("otp:#{email}")
  end
end
```

### Ruby Global Variable Rules
- **`$var`**: Global variable, accessible from anywhere
- **`@var`**: Instance variable, accessible within object instance
- **`@@var`**: Class variable, accessible within class hierarchy

### Why This Works in Rails
Rails loads all initializers before loading other classes:

```ruby
# Rails boot order:
1. Load config/application.rb
2. Load all files in config/initializers/ (including redis.rb)
3. Load app/models/, app/controllers/, app/services/
4. Start server

# So $redis is set before any service/controller needs it
```

### Better Alternative (Dependency Injection)

```ruby
# config/initializers/redis.rb
RedisClient = Redis.new(url: ENV['REDIS_URL'])

# app/services/otp_service.rb
class OtpService
  def self.redis_client
    @redis_client ||= RedisClient
  end
  
  def self.generate(email)
    self.redis_client.setex("otp:#{email}", 300, code)
  end
end
```

---

## 5. Redis GET/DEL Methods Deep Dive

### Redis Commands and Ruby Mapping

```ruby
# Redis command line
redis> SET otp:user@email.com 123456 EX 300
redis> GET otp:user@email.com  
redis> DEL otp:user@email.com

# Ruby redis gem equivalent
$redis.setex("otp:#{email}", 300, "123456")  # SET with EXpiration
$redis.get("otp:#{email}")                    # GET value
$redis.del("otp:#{email}")                    # DELETE key
```

### Method Variations

```ruby
# SET with options
$redis.set("key", "value", ex: 300, nx: true)
# ex: expiration in seconds
# nx: only set if key doesn't exist (prevents overwriting)

# GET with default
$redis.get("key") || "default_value"

# Multiple operations
$redis.mget("key1", "key2", "key3")  # Get multiple values
$redis.mdel("key1", "key2")          # Delete multiple keys

# Check existence
$redis.exists("key")  # Returns 1 if exists, 0 if not
```

### Atomic Operations

```ruby
# Redis guarantees atomicity - no race conditions
def self.consume_otp(email, code)
  # This is atomic - either both succeed or neither
  stored_code = $redis.get("otp:#{email}")
  if stored_code == code
    $redis.del("otp:#{email}")  # Delete only if code matches
    true
  else
    false
  end
end
```

---

## 6. Preventing Unlimited Account Creation

### Current Vulnerability
```ruby
# Anyone can request OTP for any email
POST /auth/request-otp
{ "email": "random@email.com" }

# System creates account on first successful auth
```

### Prevention Strategies

#### Option 1: Email Verification
```ruby
# Require email verification before OTP
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :email_verified, inclusion: { in: [true] }
  
  def self.find_or_create_verified(email)
    user = find_by(email: email)
    return user if user&.email_verified?
    
    nil  # Don't auto-create unverified accounts
  end
end
```

#### Option 2: Whitelist Domains
```ruby
# config/initializers/auth_whitelist.rb
ALLOWED_DOMAINS = %w[company.com trusted-partners.com]

class Api::AuthController < ApplicationController
  def request_code
    domain = email.split('@').last
    
    unless ALLOWED_DOMAINS.include?(domain)
      render json: { error: 'Email domain not allowed' }, status: :forbidden
      return
    end
    
    # Continue with OTP generation...
  end
end
```

#### Option 3: Admin Approval
```ruby
class User < ApplicationRecord
  enum :status, [:pending, :approved, :suspended]
  
  def self.find_or_create_approved(email)
    user = find_by(email: email)
    return user if user&.approved?
    
    nil  # Only return approved users
  end
end
```

#### Option 4: Rate Limiting by Email
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('otp/email', limit: 3, period: 1.hour) do |req|
    req.params['email'] if req.path == '/api/auth/request-otp'
  end
end
```

---

## 7. API Usage Statistics

### Adding Analytics to Track Usage

```ruby
# app/models/api_usage.rb
class ApiUsage < ApplicationRecord
  belongs_to :user
  
  validates :endpoint, presence: true
  validates :method, presence: true
  validates :ip_address, presence: true
end

# app/controllers/concerns/trackable.rb
module Trackable
  extend ActiveSupport::Concern
  
  included do
    after_action :track_api_usage
  end
  
  private
  
  def track_api_usage
    return unless current_user  # Only track authenticated requests
    
    ApiUsage.create!(
      user: current_user,
      endpoint: request.path,
      method: request.method,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      response_time: Time.now - request_start_time
    )
  end
end

# Apply to controllers
class Api::PatientsController < ApplicationController
  include Trackable
  include Authenticable
  
  def index
    @request_start_time = Time.now  # For response time tracking
    # ... controller logic
  end
end
```

### Analytics Dashboard

```ruby
# app/controllers/api/analytics_controller.rb
class Api::AnalyticsController < ApplicationController
  include Authenticable
  
  def usage_stats
    # Only admins can view stats
    authorize_admin!
    
    stats = {
      total_requests: ApiUsage.count,
      unique_users: ApiUsage.distinct.count(:user_id),
      top_endpoints: ApiUsage.group(:endpoint).count,
      requests_by_hour: ApiUsage.group_by_hour('created_at', 24).count,
      avg_response_time: ApiUsage.average(:response_time)
    }
    
    render json: stats
  end
  
  private
  
  def authorize_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
```

---

## 8. Ruby "begin" Keyword

### Exception Handling with begin/rescue

```ruby
# Basic exception handling
begin
  # Code that might fail
  result = risky_operation()
rescue StandardError => e
  # Handle any error
  puts "Error: #{e.message}"
end

# Specific exception handling
begin
  payload = JwtService.decode(token)
rescue JWT::DecodeError
  render json: { error: 'Invalid token format' }, status: :unauthorized
rescue JWT::ExpiredSignature  
  render json: { error: 'Token expired' }, status: :unauthorized
rescue JWT::VerificationError
  render json: { error: 'Token verification failed' }, status: :unauthorized
end

# Ensure code runs (finally equivalent)
begin
  token = JwtService.decode(request_token)
  # ... use token
rescue JWT::DecodeError
  render json: { error: 'Invalid token' }, status: :unauthorized
ensure
  # This ALWAYS runs, success or failure
  Rails.logger.info("Authentication attempt from #{request.ip}")
end
```

### begin/rescue/else/end

```ruby
begin
  result = some_operation()
rescue SpecificError
  handle_specific_error()
else
  # Only runs if NO exception was raised
  puts "Operation succeeded: #{result}"
end
```

---

## 9. Secrets: JWT_SECRET vs Rails Credentials

### Environment Variables (Simple but Less Secure)

```bash
# .env file (should be in .gitignore!)
JWT_SECRET=your_secret_key_here

# Ruby code
secret = ENV['JWT_SECRET']
```

**Problems:**
- ✅ Easy to set up
- ❌ Exposed in logs, process lists
- ❌ Accidentally committed to git
- ❌ Same secret across all environments

### Rails Credentials (Recommended)

```bash
# Edit encrypted credentials
rails credentials:edit

# config/credentials.yml.enc (encrypted)
jwt_secret: production_super_secret_key_here
development:
  jwt_secret: dev_secret_key_here
test:
  jwt_secret: test_secret_key_here
```

```ruby
# Ruby code - secure and environment-specific
secret = Rails.application.credentials.jwt_secret

# Or environment-specific
secret = Rails.application.credentials.dig(:development, :jwt_secret)
```

### Why Rails Credentials is Better

```ruby
# Rails credentials provide:
1. Encryption: Files are encrypted with master key
2. Environment-specific: Different secrets per environment
3. Source control safe: Encrypted files can be committed
4. Audit trail: Changes to credentials are tracked
5. Team access: Master key can be shared securely

# Master key management
config/master.key  # Never commit this file!
# Or use Rails credentials:edit with EDITOR=vim  # Uses your key
```

### Best Practices for Secrets

```ruby
# ❌ Don't hardcode secrets
class JwtService
  SECRET_KEY = "super_secret_key_123"  # BAD!
end

# ✅ Use Rails credentials
class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret  # GOOD!
end

# ✅ Environment validation
class JwtService
  def self.secret_key
    secret = Rails.application.credentials.jwt_secret
    raise "JWT_SECRET not configured" if secret.blank?
    secret
  end
end
```

---

## 10. Server Memory Sizing for Redis

### Calculating Memory Requirements

```ruby
# Memory calculation for 1000 concurrent users
# Each OTP entry: ~50 bytes (email + code + Redis overhead)

# Basic calculation
memory_per_user = 50  # bytes
concurrent_users = 1000
total_memory_mb = (memory_per_user * concurrent_users) / (1024 * 1024)
# Result: ~48 MB

# Add Redis overhead (25% safety margin)
recommended_memory_mb = total_memory_mb * 1.25
# Result: ~60 MB for 1000 users
```

### Memory Planning for Different Scales

```ruby
# Scaling calculations
def calculate_redis_memory(users, otp_expiry_minutes = 5)
  # Each user: email(~30 chars) + code(6) + Redis overhead(~14)
  bytes_per_user = 50
  concurrent_users = users * (otp_expiry_minutes / 5.0)  # 5-minute windows
  total_mb = (bytes_per_user * concurrent_users) / (1024 * 1024)
  
  puts "#{users} users need ~#{total_mb.round(1)}MB Redis memory"
  total_mb
end

# Examples:
calculate_redis_memory(100)    # ~5 MB
calculate_redis_memory(1000)   # ~48 MB  
calculate_redis_memory(10000)  # ~477 MB
```

### Production Server Recommendations

```bash
# For 1000 concurrent users:
# Minimum: 512 MB RAM (8x current need)
# Recommended: 1 GB RAM (16x current need)
# Optimal: 2 GB RAM (32x current need)

# Redis configuration for production
redis.conf:
maxmemory 512mb
maxmemory-policy allkeys-lru  # Remove least recently used when full
```

---

## 11. REDIS_URL in Production Deployment

### Deployment Configuration Changes

```bash
# Development (.env)
REDIS_URL=redis://localhost:6379

# Staging (environment variables)
export REDIS_URL=redis://staging-redis.internal:6379

# Production (environment variables)  
export REDIS_URL=redis://prod-redis-cluster.internal:6379
```

### Environment-Specific Configuration

```ruby
# config/initializers/redis.rb - Production-ready
case Rails.env
when 'production'
  redis_url = ENV['REDIS_URL'] || 'redis://prod-redis.internal:6379'
when 'staging'  
  redis_url = ENV['REDIS_URL'] || 'redis://staging-redis.internal:6379'
when 'development'
  redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379'
when 'test'
  redis_url = 'redis://localhost:6379/1'  # Separate DB for tests
end

$redis = Redis.new(
  url: redis_url,
  ssl: Rails.env.production?,  # SSL in production
  reconnect_attempts: 3,
  timeout: 5
)
```

### Deployment Considerations

```yaml
# docker-compose.yml (production)
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
    environment:
      - REDIS_URL=redis://redis:6379
    volumes:
      - redis_data:/data
  
  app:
    image: patient-nutrition-api:latest
    environment:
      - REDIS_URL=redis://redis:6379
      - RAILS_ENV=production
    depends_on:
      - redis
```

### Configuration Management

```ruby
# config/environments/production.rb
config.redis_url = ENV.fetch('REDIS_URL') {
  raise 'REDIS_URL environment variable not set in production'
}

# Health check for Redis
config.after_initialize do
  begin
    Redis.new(url: config.redis_url).ping
  rescue Redis::CannotConnectError => e
    Rails.logger.error "Cannot connect to Redis: #{e.message}"
    raise "Redis connection failed - check REDIS_URL configuration"
  end
end
```

---

## 12. Updated Test Plan with SecureRandom

### 3. Use SecureRandom for OTP Generation

```ruby
# app/services/otp_service.rb (UPDATED)
require 'securerandom'

class OtpService
  def self.generate(email)
    # ✅ Cryptographically secure random number
    code = SecureRandom.random_number(100000..999999).to_s
    
    # Store in Redis with 5-minute expiration
    $redis.setex("otp:#{email}", 300, code)
    
    # Log for audit trail
    Rails.logger.info("OTP generated for #{email}")
    
    code
  end
  
  def self.verify(email, code)
    stored_code = $redis.get("otp:#{email}")
    is_valid = stored_code == code && !stored_code.nil?
    
    Rails.logger.info("OTP verification for #{email}: #{is_valid ? 'SUCCESS' : 'FAILED'}")
    is_valid
  end
  
  def self.consume(email)
    deleted = $redis.del("otp:#{email}")
    Rails.logger.info("OTP consumed for #{email}: #{deleted ? 'SUCCESS' : 'NOT_FOUND'}")
    deleted > 0
  end
end
```

### Test Updates for SecureRandom

```ruby
# spec/services/otp_service_spec.rb
RSpec.describe OtpService do
  describe '.generate' do
    it 'generates cryptographically secure OTP codes' do
      # Test multiple generations for randomness
      codes = Array.new(100) { OtpService.generate('test@example.com') }
      
      # Verify all codes are different
      expect(codes.uniq.length).to eq(100)
      
      # Verify format (6 digits)
      codes.each do |code|
        expect(code).to match(/^\d{6}$/)
      end
    end
    
    it 'stores OTP with correct expiration' do
      email = 'test@example.com'
      code = OtpService.generate(email)
      
      # Verify Redis storage
      stored_code = $redis.get("otp:#{email}")
      expect(stored_code).to eq(code)
      
      # Verify TTL (time to live)
      ttl = $redis.ttl("otp:#{email}")
      expect(ttl).to be_between(1, 300)  # Between 1 and 300 seconds
    end
  end
end
```

---

## 13. Dependency Injection in Ruby

### How Dependency Injection Works

DI is providing dependencies from outside rather than creating them inside:

```ruby
# ❌ Hard-coded dependency (bad)
class OtpService
  def self.generate(email)
    redis = Redis.new(url: 'redis://localhost:6379')  # Hard-coded!
    redis.setex("otp:#{email}", 300, code)
  end
end

# ✅ Dependency injection (good)
class OtpService
  def self.redis_client
    @redis_client ||= Redis.new(url: ENV['REDIS_URL'])
  end
  
  def self.generate(email)
    self.redis_client.setex("otp:#{email}", 300, code)
  end
end
```

### DI Patterns in Ruby

#### Pattern 1: Constructor Injection
```ruby
class OtpService
  def initialize(redis_client)
    @redis_client = redis_client
  end
  
  def generate(email)
    @redis_client.setex("otp:#{email}", 300, code)
  end
end

# Usage
redis = Redis.new(url: ENV['REDIS_URL'])
otp_service = OtpService.new(redis)
```

#### Pattern 2: Class-level Injection (Rails Style)
```ruby
# config/initializers/dependencies.rb
RedisClient = Redis.new(url: ENV['REDIS_URL'])

# app/services/otp_service.rb
class OtpService
  def self.redis_client
    @redis_client ||= RedisClient
  end
end
```

#### Pattern 3: Module Injection
```ruby
# app/services/otp_service.rb
module RedisConnection
  def redis_client
    @redis_client ||= Redis.new(url: redis_url)
  end
  
  private
  
  def redis_url
    ENV['REDIS_URL'] || 'redis://localhost:6379'
  end
end

class OtpService
  include RedisConnection
  
  def self.generate(email)
    redis_client.setex("otp:#{email}", 300, code)
  end
end
```

### How Rails Initializers Enable DI

```ruby
# Rails loads files in this order:
1. config/application.rb          # Rails configuration
2. config/environments/*.rb       # Environment-specific settings  
3. config/initializers/*.rb     # All initializers (alphabetical)
4. app/models/, controllers/, etc. # Application code

# So by step 3, we can set up dependencies
# By step 4, all app code can use them
```

### Benefits of Dependency Injection

```ruby
# ✅ Testability
class OtpServiceTest < Minitest::Test
  def setup
    # Inject mock Redis for testing
    @mock_redis = MockRedis.new
    OtpService.redis_client = @mock_redis
  end
end

# ✅ Flexibility  
class OtpService
  def self.redis_client
    # Different clients for different environments
    case Rails.env
    when 'test'
      @redis_client ||= MockRedis.new
    when 'production'
      @redis_client ||= Redis.new(url: ENV['REDIS_URL'], ssl: true)
    else
      @redis_client ||= Redis.new(url: ENV['REDIS_URL'])
    end
  end
end

# ✅ Single Responsibility
class OtpService
  # Only handles OTP logic, not Redis connection details
  def self.generate(email)
    redis_client.setex("otp:#{email}", 300, code)
  end
end
```

---

## 14. JWT_SECRET - Why We Need It

### JWT Security Fundamentals

JWT (JSON Web Token) has three parts: Header.Payload.Signature

```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.signature_hash_here
│─────────────────│─────────────────────│─────────────────────│
│    Header       │     Payload      │     Signature      │
```

### Why JWT_SECRET is Critical

```ruby
# Without secret, anyone can forge tokens
payload = { user_id: 1, exp: Time.now + 1.hour }
fake_token = JWT.encode(payload, nil, 'none')  # NO SIGNATURE!

# With secret, only server can create valid tokens
real_token = JWT.encode(payload, 'super_secret_key', 'HS256')
```

### How JWT_SECRET Works

```ruby
# Signing process
def self.encode(payload)
  # 1. Convert payload to JSON
  json_payload = payload.to_json
  
  # 2. Create signature using secret key
  signature = HMACSHA256(json_payload, JWT_SECRET)
  
  # 3. Combine: base64(header) + "." + base64(payload) + "." + base64(signature)
  "#{encoded_header}.#{encoded_payload}.#{encoded_signature}"
end

# Verification process
def self.decode(token)
  # 1. Split token into parts
  header, payload, signature = token.split('.')
  
  # 2. Recreate signature using stored secret
  expected_signature = HMACSHA256("#{header}.#{payload}", JWT_SECRET)
  
  # 3. Compare signatures (constant-time comparison)
  valid_signature = secure_compare(signature, expected_signature)
  
  # 4. Return payload only if signatures match
  valid_signature ? JSON.parse(base64_decode(payload)) : raise("Invalid signature")
end
```

### Security Requirements for JWT_SECRET

```ruby
# ❌ Weak secrets (easily guessed)
JWT_SECRET = "password123"
JWT_SECRET = "secret"
JWT_SECRET = "jwt_key"

# ✅ Strong secrets (cryptographically secure)
JWT_SECRET = "k9J2m5P8vF7x3Q1rN6wY4tZ8sB5mH7gD3cL9vJ2qX8fW5zR1nK7pE3sT6yU4iO0aA1dF2"

# Secret requirements:
# - At least 32 characters
# - Random (not dictionary words)
# - Mix of upper/lower/numbers/symbols
# - Never committed to version control
# - Different per environment
```

### Rails Credentials for JWT_SECRET

```bash
# Generate secure secret
openssl rand -base64 32

# Edit Rails credentials
rails credentials:edit

# Add to encrypted file:
jwt_secret: k9J2m5P8vF7x3Q1rN6wY4tZ8sB5mH7gD3cL9vJ2qX8fW5zR1nK7pE3sT6yU4iO0aA1dF2
development:
  jwt_secret: dev_secret_for_testing_only
test:
  jwt_secret: test_secret_for_testing_only
```

### Environment-Specific Secrets

```ruby
# app/services/jwt_service.rb
class JwtService
  def self.secret_key
    secret = Rails.application.credentials.jwt_secret
    
    case Rails.env
    when 'production'
      raise "JWT_SECRET not configured for production" if secret.blank?
    when 'development', 'test'
      secret ||= 'development_fallback_secret'  # Only for dev!
    end
    
    secret
  end
  
  def self.encode(payload)
    JWT.encode(payload, secret_key, 'HS256')
  end
end
```

### Secret Rotation Strategy

```ruby
# For production security, rotate secrets periodically
class JwtService
  def self.secret_key
    # Support multiple active secrets during rotation
    primary_secret = Rails.application.credentials.jwt_secret
    fallback_secret = Rails.application.credentials.jwt_secret_fallback
    
    # Try primary first, then fallback
    [primary_secret, fallback_secret].compact.first
  end
end
```

---

## Summary: Security Best Practices

1. **Use SecureRandom** for OTP codes
2. **Environment variables** for configuration
3. **Rails credentials** for secrets
4. **Rate limiting** for abuse prevention
5. **Audit logging** for security monitoring
6. **Input validation** for all parameters
7. **HTTPS only** for production
8. **Short expiration** for temporary data
9. **Memory planning** for Redis scaling
10. **Dependency injection** for testable code
11. **Strong JWT secrets** for token security
12. **Environment-specific** configurations

These concepts form the foundation of secure, scalable Rails applications.
