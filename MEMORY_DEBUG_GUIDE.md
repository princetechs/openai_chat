# Memory Debug Guide

This guide explains how to control memory response visibility in the AI chat application.

## Problem Solved

**Issue:** Memory extraction JSON responses were showing in the chat interface, creating poor UX.

**Solution:** Implemented clean response parsing with optional debug mode for developers.

## How It Works

### 1. Clean Chat Mode (Default)
- Users see **only** the conversational AI response
- Memory extraction happens silently in the background
- No technical artifacts or JSON data visible

### 2. Debug Mode (Developers Only)
- Shows memory extraction details for debugging
- Displays raw AI responses and memory data
- Helps developers understand memory processing

## Enabling Debug Mode

### Method 1: URL Parameter
Add `?show_memory_response=true` to any chat URL:
```
http://localhost:3000/chats/1?show_memory_response=true
```

### Method 2: Environment Variable
Set in your `.env` file:
```bash
SHOW_MEMORY_DEBUG=true
```

### Method 3: Rails Console
```ruby
# Temporarily enable for testing
ENV['SHOW_MEMORY_DEBUG'] = 'true'

# Test memory service
memory_service = AiMemory::MemoryService.new(user_id: 'test', session_id: 'test')
puts memory_service.get_memory_stats
```

## Response Processing Flow

```
AI Raw Response → Response Parser → Clean Response + Debug Info (optional)
                                ↓
                           Display to User
                                ↓
                        Background Memory Extraction
```

### Response Parser Logic
```ruby
def parse_ai_response(raw_content)
  # Clean response for users
  {
    response: raw_content.strip,
    memory_data: nil,
    debug_info: show_memory_debug? ? { 
      raw_content: raw_content, 
      timestamp: Time.current 
    } : nil
  }
end
```

## System Prompt Changes

### Before (Problematic)
```
You are a helpful AI assistant that replies to user input and simultaneously extracts key information...
Output your response and memory extraction in a JSON object...
```

### After (Clean)
```
You are a helpful AI assistant. Respond naturally and conversationally to the user's messages.
- Respond ONLY with your conversational reply - no JSON, no metadata, no technical artifacts
- Your response should be natural conversation only.
```

## Benefits

### For Users
- ✅ Clean, natural chat experience
- ✅ No technical artifacts or JSON responses
- ✅ Faster, more responsive interface
- ✅ Professional appearance

### For Developers
- ✅ Optional debug mode for troubleshooting
- ✅ Memory extraction still works in background
- ✅ Easy to enable/disable debug features
- ✅ Comprehensive logging and monitoring

## Testing Debug Mode

1. **Enable debug mode:**
   ```bash
   export SHOW_MEMORY_DEBUG=true
   ```

2. **Start Rails server:**
   ```bash
   rails server
   ```

3. **Send a chat message and observe:**
   - Normal response for users
   - Debug info appended for developers

4. **Check memory extraction:**
   ```bash
   tail -f log/development.log | grep "AiMemory"
   ```

## Configuration Options

### In Rails Application
```ruby
# config/application.rb or controller
class MessagesController < ApplicationController
  private
  
  def show_memory_debug?
    # Customize debug conditions
    params[:show_memory_response] == 'true' || 
    Rails.env.development? && ENV['SHOW_MEMORY_DEBUG'] == 'true' ||
    current_user&.admin? # Example: only for admin users
  end
end
```

### In AiMemory Gem
```ruby
# config/initializers/ai_memory.rb
AiMemory.configure do |config|
  # Enable debug logging
  config.logger = Rails.logger
  
  # Adjust extraction settings
  config.extraction_temperature = 0.1
  config.extraction_max_tokens = 800
end
```

## Production Considerations

- **Always disable debug mode in production** unless needed for specific troubleshooting
- Memory extraction continues working regardless of debug mode
- Debug info is only added to chat messages, not stored in memory files
- Performance impact of debug mode is minimal

## Troubleshooting

### Memory Not Extracting
1. Check AiMemory gem configuration
2. Verify OpenAI API key
3. Enable debug mode to see extraction attempts
4. Check Rails logs for background thread errors

### Debug Mode Not Working
1. Verify environment variable: `echo $SHOW_MEMORY_DEBUG`
2. Check URL parameter: `?show_memory_response=true`
3. Restart Rails server after environment changes
4. Check controller logic in `show_memory_debug?` method

This system provides the best of both worlds: clean UX for users and powerful debugging for developers.
