# Require the faraday-retry middleware
require 'faraday/retry'

# Define retry options for API clients
retry_options = {
  max: 3,
  interval: 0.5,
  interval_randomness: 0.5,
  backoff_factor: 2,
  exceptions: [
    Faraday::ConnectionFailed,
    Faraday::TimeoutError,
    'Timeout::Error',
    'Errno::ETIMEDOUT'
  ]
}

# Configure OpenRouter (commented out since we're using OpenAI directly)
# OpenRouter.configure do |config|
#     config.faraday do |f|
#       f.request :retry, retry_options
#       f.response :logger, Logger.new($stdout), { headers: true, bodies: true, errors: true } do |logger|
#         logger.filter(/(Bearer) (\S+)/, '\1[REDACTED]')
#       end
#     end
# end

Raix.configure do |config|
    # We'll create a simple class to handle OpenRouter client calls
    dummy_client = Class.new do
      def complete(*args, **kwargs)
        raise "OpenRouter client not configured"
      end
    end
    
    # Set the OpenRouter client to our dummy client
    config.openrouter_client = dummy_client.new
    config.openai_client = OpenAI::Client.new(access_token: ENV.fetch("OAI_ACCESS_TOKEN", "")) do |f|
      f.request :retry, retry_options
      f.response :logger, Logger.new($stdout), { headers: true, bodies: true, errors: true } do |logger|
        logger.filter(/(Bearer) (\S+)/, '\1[REDACTED]')
      end
    end
end

