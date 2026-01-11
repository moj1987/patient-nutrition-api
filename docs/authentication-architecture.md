# Authentication Architecture Deep Dive

## Overview
This document explains how the Email OTP + JWT authentication system works in Rails, including the Ruby/Rails magic that makes it all function together.

## Core Components

### 1. Redis - OTP Code Storage

#### What is Redis?
Redis is an in-memory key-value store that's perfect for temporary data like OTP codes.

#### How Ruby Works with Redis
```ruby
# Gemfile
gem 'redis'

# config/initializers/redis.rb
$redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')

# app/services/otp_service.rb
class OtpService
  def self.generate(email)
    code = rand(100000..999999).to_s
    # Redis SET with expiration (5 minutes)
    $redis.setex("otp:#{email}", 300, code)
    code
  end
  
  def self.verify(email, code)
    stored_code = $redis.get("otp:#{email}")
    stored_code == code
  end
  
  def self.consume(email)
    $redis.del("otp:#{email}")
  end
end
```

#### Ruby Magic Explained
- **`$redis`**: Global variable (starts with $) accessible throughout the application
- **`setex`**: Redis command to SET with EXpiration time
- **`get`/`del`**: Basic Redis operations mapped to Ruby methods
- **Connection pooling**: Redis gem handles connection management automatically

#### Why Redis vs Database?
- **Speed**: In-memory storage is much faster than disk
- **Auto-cleanup**: Keys automatically expire, no cleanup code needed
- **Atomic operations**: Redis guarantees thread-safe operations

---

### 2. AuthenticationMailer - Email Delivery

#### How Rails Mailers Work
```ruby
# app/mailers/authentication_mailer.rb
class AuthenticationMailer < ApplicationMailer
  def otp_code(email, code)
    @email = email
    @code = code
    @expires_in = 5.minutes
    
    mail(to: email, subject: 'Your Authentication Code')
  end
end

# app/views/authentication_mailer/otp_code.html.erb
<h1>Your Authentication Code</h1>
<p>Use this code to access the Patient Nutrition API:</p>
<h2><%= @code %></h2>
<p>This code expires in <%= @expires_in %> minutes.</p>

# app/views/authentication_mailer/otp_code.text.erb
Your Authentication Code: <%= @code %>
Expires in: <%= @expires_in %> minutes
```

#### Ruby/Rails Magic Explained
- **Inheritance**: `ApplicationMailer` provides email functionality
- **Instance variables**: `@email`, `@code` automatically available in views
- **Dual templates**: Rails automatically renders HTML and text versions
- **`mail()` method**: Rails ActionMailer method to send emails

#### Configuration
```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: 'localhost:3000' }

# config/environments/production.rb  
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  # ... other SMTP settings
}
```

---

### 3. JwtService - Token Generation & Validation

#### JWT (JSON Web Tokens) in Ruby
```ruby
# Gemfile
gem 'jwt'

# app/services/jwt_service.rb
class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret
  
  def self.encode(payload)
    # Add standard JWT claims
    payload[:exp] = 5.minutes.from_now.to_i  # Expiration
    payload[:iat] = Time.now.to_i             # Issued at
    payload[:iss] = 'patient-nutrition-api'  # Issuer
    
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end
  
  def self.decode(token)
    # Decode with verification
    decoded = JWT.decode(token, SECRET_KEY, true, { 
      algorithm: 'HS256',
      iss: 'patient-nutrition-api'  # Verify issuer
    })
    decoded.first  # Return payload hash
  end
end
```

#### Ruby Magic Explained
- **Class methods**: `self.encode` and `self.decode` - no instantiation needed
- **`Rails.application.credentials`**: Encrypted credentials storage
- **Hash symbols**: `payload[:exp]` - Ruby's hash access syntax
- **Time calculations**: `5.minutes.from_now` - Rails' ActiveSupport extensions

#### JWT Structure
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2NDEwNjQ4MDB9.signature
│─────────────────│─────────────────────────────────────│─────────────────│
│    Header       │               Payload               │    Signature    │
│   (algorithm)   │  (user_id, exp, iat, iss)         │   (HMAC hash)   │
```

---

### 4. Routes - Authentication Endpoints

#### Route Configuration
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Public endpoints (no auth required)
  namespace :api do
    namespace :auth do
      post :request_code  # POST /api/auth/request_code
      post :token         # POST /api/auth/token
    end
  end
  
  # Protected endpoints (auth required)
  namespace :api do
    resources :patients, only: [:index, :show, :create, :update, :destroy]
    resources :food_items, only: [:index, :show, :create]
    # ... other routes
  end
end
```

#### How Rails Routes Work
- **`namespace`**: Creates URL prefix (/api/auth/request_code)
- **RESTful routing**: `resources` creates standard CRUD routes
- **HTTP verbs**: `post`, `get`, `patch`, `delete` map to controller actions
- **Route helpers**: Rails generates methods like `api_auth_request_code_path`

---

## Authentication Flow - Complete Picture

### Step 1: Request OTP Code
```ruby
# app/controllers/api/auth_controller.rb
class Api::AuthController < ApplicationController
  def request_code
    email = params.require(:email)
    
    # Validate email format
    unless email.match?(/\A[^@\s]+@[^@\s]+\z/)
      render json: { error: 'Invalid email format' }, status: :bad_request
      return
    end
    
    # Generate and store OTP
    code = OtpService.generate(email)
    
    # Send email
    AuthenticationMailer.otp_code(email, code).deliver_now
    
    render json: { message: 'Code sent to email' }
  end
end
```

### Step 2: Verify OTP & Issue Token
```ruby
def token
  email = params.require(:email)
  code = params.require(:code)
  
  unless OtpService.verify(email, code)
    render json: { error: 'Invalid or expired code' }, status: :unauthorized
    return
  end
  
  # Consume OTP (prevent reuse)
  OtpService.consume(email)
  
  # Find or create user
  user = User.find_or_create_by(email: email)
  
  # Issue JWT token
  token = JwtService.encode({ user_id: user.id })
  
  render json: { 
    token: token,
    expires_in: 300,
    user: { id: user.id, email: user.email }
  }
end
```

### Step 3: Protect API Endpoints
```ruby
# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_request!
  end
  
  private
  
  def authenticate_request!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.nil?
      render json: { error: 'Token required' }, status: :unauthorized
      return
    end
    
    begin
      payload = JwtService.decode(token)
      @current_user = User.find(payload['user_id'])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end

# Apply to controllers
class Api::PatientsController < ApplicationController
  include Authenticable
  
  def index
    patients = Patient.where(user: current_user)
    render json: patients
  end
end
```

---

## Ruby/Rails Concepts for Senior Developers

### 1. Metaprogramming & Concerns
```ruby
# ActiveSupport::Concern provides module inclusion hooks
module Authenticable
  extend ActiveSupport::Concern
  
  # Code to run when module is included
  included do
    before_action :authenticate_request!
  end
  
  # Instance methods become available in including class
  private
  
  def authenticate_request!
    # ...
  end
end
```

### 2. Service Objects Pattern
```ruby
# Plain Ruby objects for business logic
class OtpService
  # Class methods - no state, just operations
  def self.generate(email)
    # Pure function: input -> output
  end
end
```

### 3. Rails Conventions
- **Naming**: `AuthenticationMailer` -> `authentication_mailer.rb`
- **Autoloading**: Rails automatically loads classes when referenced
- **Convention over Configuration**: Default behaviors that "just work"

### 4. Dependency Injection
```ruby
# Rails automatically injects dependencies
class ApplicationController < ActionController::API
  # `render`, `params`, `request` available without explicit injection
end
```

### 5. Error Handling Patterns
```ruby
# Ruby exception handling
begin
  payload = JwtService.decode(token)
rescue JWT::DecodeError
  # Handle specific JWT errors
rescue StandardError => e
  # Catch-all for other errors
end
```

### 6. Hash & Symbol Usage
```ruby
# Ruby symbols vs strings
params[:email]      # Symbol key (preferred)
params['email']     # String key (works but slower)

# Hash with symbol keys
payload = { user_id: user.id, exp: time.to_i }
# vs
payload = { 'user_id' => user.id, 'exp' => time.to_i }
```

---

## Security Considerations

### 1. Rate Limiting
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('otp_requests/ip', limit: 5, period: 60) do |req|
    req.ip if req.path == '/api/auth/request_code' && req.post?
  end
end
```

### 2. Environment Variables
```bash
# .env
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_super_secret_random_string_here
```

### 3. Rails Credentials
```bash
rails credentials:edit
# Add encrypted secrets
jwt_secret: production_secret_here
```

---

## Testing the Authentication System

### RSpec Tests
```ruby
# spec/requests/api/auth_spec.rb
RSpec.describe 'POST /api/auth/request_code' do
  it 'sends OTP code' do
    post '/api/auth/request_code', params: { email: 'test@example.com' }
    
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['message']).to include('sent')
  end
end
```

---

## Key Takeaways for Rails Newcomers

1. **Convention over Configuration**: Rails makes decisions for you
2. **Autoloading**: No need for require/import statements
3. **Active Record**: Database access becomes method calls
4. **Service Objects**: Keep controllers thin, business logic in services
5. **Modules/Concerns**: Share code across controllers cleanly
6. **Environment Management**: Different configs for dev/test/prod
7. **Testing Integration**: Built-in testing framework with everything

This architecture demonstrates Rails' philosophy: make common tasks simple, complex tasks possible.
