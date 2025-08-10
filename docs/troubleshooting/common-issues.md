# Common Issues and Solutions

## Fixed Issues ✅

### 1. Namespace Errors
**Error**: `uninitialized constant MessagesController::Memory`

**Solution**: Use absolute namespace references
```ruby
# Before (incorrect)
Memory::MemoryEnhancedChatService.new

# After (correct)
::Memory::MemoryEnhancedChatService.new
```

### 2. Missing current_user Method
**Error**: `undefined local variable or method 'current_user'`

**Solution**: Added helper method to controllers
```ruby
def current_user
  nil # Return nil for now, can be updated when authentication is added
end
```

## Potential Issues

### 3. Faraday Retry Errors
**Error**: `:retry is not registered on Faraday::Request`

**Solution**: Ensure faraday-retry gem is installed and required
```ruby
# Gemfile
gem 'faraday-retry'

# config/initializers/raix.rb
require 'faraday/retry'
```

### 4. OpenAI Token Limits
**Error**: `max_tokens is too large: 16384`

**Solution**: Set appropriate token limits for your model
```ruby
params[:max_completion_tokens] = 4000  # For GPT-3.5-turbo
```

### 5. Memory Extraction Failures
**Error**: JSON parsing errors in memory extraction

**Symptoms**:
- Empty memory responses
- Invalid JSON format from AI
- Memory extraction timeouts

**Solutions**:
```ruby
# Add better error handling
begin
  response = chat_completion(json: true)
rescue JSON::ParserError => e
  Rails.logger.error("Memory extraction JSON error: #{e.message}")
  return { "session_memories" => [], "user_memories" => [] }
end
```

### 6. File Permission Issues
**Error**: Permission denied when creating memory files

**Solution**:
```bash
# Ensure storage directory is writable
chmod 755 storage/
mkdir -p storage/memories
chmod 755 storage/memories
```

### 7. Large Memory Files
**Issue**: Memory files becoming too large

**Solutions**:
- Implement memory cleanup strategies
- Set stricter limits on memory count
- Compress old memories
- Archive old sessions

```ruby
# Example cleanup in MemoryStorageService
def cleanup_old_memories
  memories = memories.select { |m| Time.parse(m["timestamp"]) > 30.days.ago }
end
```

## Debugging Tips

### 1. Enable Detailed Logging
```ruby
# In development.rb
config.log_level = :debug

# Add to services for detailed memory logging
Rails.logger.info("Extracted #{memories.count} memories from conversation")
```

### 2. Check Memory File Contents
```bash
# View user memories
cat storage/memories/user_anonymous_[session_id].json | jq .

# View session memories  
cat storage/memories/session_[session_id].json | jq .
```

### 3. Test Memory Extraction Manually
```ruby
# In Rails console
extractor = Memory::MemoryExtractionService.new(user_id: 'test', session_id: 'test')
messages = [
  { role: 'user', content: 'Hi, my name is John and I love pizza' },
  { role: 'assistant', content: 'Nice to meet you John! Pizza is delicious.' }
]
result = extractor.extract_memories_from_conversation(messages)
puts result.inspect
```

### 4. Verify Service Loading
```ruby
# In Rails console
Memory::BaseMemoryService.new
Memory::MemoryExtractionService.new(user_id: 'test', session_id: 'test')
```

## Performance Issues

### 1. Slow Memory Extraction
**Symptoms**: Long response times, timeouts

**Solutions**:
- Reduce conversation context size
- Use faster AI models
- Implement background processing
- Cache frequently accessed memories

### 2. Large Memory Files
**Solutions**:
```ruby
# Implement pagination for large memory sets
def get_recent_memories(limit = 20)
  memories.sort_by { |m| Time.parse(m["timestamp"]) }.last(limit)
end
```

### 3. Frequent File I/O
**Solutions**:
- Implement in-memory caching
- Batch memory updates
- Use database storage for high-traffic applications

## API Issues

### 1. OpenAI Rate Limits
**Error**: Rate limit exceeded

**Solutions**:
- Implement exponential backoff
- Use retry middleware (already configured)
- Consider using multiple API keys
- Implement request queuing

### 2. Network Timeouts
**Solutions**:
```ruby
# Increase timeout in Raix configuration
config.openai_client = OpenAI::Client.new(
  access_token: ENV.fetch("OAI_ACCESS_TOKEN"),
  request_timeout: 60  # Increase timeout
)
```

## Development Tips

### 1. Reset Memory State
```ruby
# Clear all memories for testing
Dir.glob("storage/memories/*.json").each { |f| File.delete(f) }
```

### 2. Mock Memory Services for Testing
```ruby
# In test environment
allow(Memory::MemoryExtractionService).to receive(:new).and_return(mock_service)
```

### 3. Environment-Specific Configuration
```ruby
# Different memory limits per environment
MEMORY_LIMITS = {
  'development' => { user: 50, session: 20 },
  'production' => { user: 200, session: 50 },
  'test' => { user: 10, session: 5 }
}
```

## Getting Help

### 1. Check Logs
```bash
tail -f log/development.log | grep -i memory
```

### 2. Enable Debug Mode
```ruby
# In Rails console
Rails.logger.level = Logger::DEBUG
```

### 3. Test Individual Components
```ruby
# Test storage
storage = Memory::MemoryStorageService.new(user_id: 'test', session_id: 'test')
storage.store_memories({"user_memories" => [{"category" => "test", "content" => "test"}]})

# Test extraction
extractor = Memory::MemoryExtractionService.new(user_id: 'test', session_id: 'test')
# ... test with sample data
```

## Next Steps
- [Error Messages Reference](errors.md)
- [Performance Optimization](performance.md)
- [Architecture Overview](../architecture/overview.md)
