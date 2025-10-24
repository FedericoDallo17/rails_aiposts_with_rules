# frozen_string_literal: true

class Rack::Attack
  # Always allow requests from localhost (for development)
  safelist("allow from localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # Throttle general API requests by IP
  throttle("api/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Throttle authentication attempts by IP address
  throttle("auth/ip", limit: 5, period: 1.minute) do |req|
    if req.path.start_with?("/api/v1/auth/") && req.post?
      req.ip
    end
  end

  # Throttle authentication attempts by email
  throttle("auth/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/api/v1/auth/sign_in" && req.post?
      req.params["email"].to_s.downcase.presence
    end
  end

  # Throttle password reset requests
  throttle("password_reset/ip", limit: 3, period: 5.minutes) do |req|
    if req.path == "/api/v1/auth/password/forgot" && req.post?
      req.ip
    end
  end

  # Throttle search requests
  throttle("search/ip", limit: 20, period: 1.minute) do |req|
    if req.path.start_with?("/api/v1/search/")
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{error: "Too many requests. Please try again later."}.to_json]
    ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack

