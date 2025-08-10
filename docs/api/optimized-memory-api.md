# Optimized Memory System API

## Overview
The optimized memory system provides a clean, efficient API for memory management in AI chat applications. This API is designed to be non-blocking, user-friendly, and highly performant.

## Core Service: OptimizedMemoryService

### Initialization
```ruby
memory_service = Memory::OptimizedMemoryService.new(
  user_id: "user_123",           # Required: Unique user identifier
  session_id: "session_456"      # Required: Session identifier
)
```

## Primary Methods

### 1. Memory Extraction and Storage

#### `extract_and_store_memories(messages, ai_response)`
Extracts and stores memories from conversation in background thread.

**Parameters:**
- `messages` (Array): Array of message hashes with `:role` and `:content`
- `ai_response` (String): The AI's response to the conversation

**Features:**
- Non-blocking background processing
- Automatic deduplication
- Conversation hash caching to prevent reprocessing
- Comprehensive error handling

**Example:**
```ruby
messages = [
  { role: 'user', content: 'Hi, my name is John and I love pizza' },
  { role: 'assistant', content: 'Nice to meet you John!' }
]

memory_service.extract_and_store_memories(messages, "Nice to meet you John!")
# Runs in background, doesn't block execution
```

### 2. Memory Retrieval

#### `get_relevant_memories_for_prompt(query_context, limit)`
Retrieves relevant memories formatted for AI prompt injection.

**Parameters:**
- `query_context` (String, optional): Current conversation context for relevance filtering
- `limit` (Integer, default: 10): Maximum number of memories to retrieve

**Returns:**
- (String): Formatted memory context for prompt injection

**Example:**
```ruby
context = memory_service.get_relevant_memories_for_prompt(
  "What food do I like?", 
  10
)

# Returns formatted string:
# === MEMORY CONTEXT ===
# Personal facts: User's name is John
# Preferences: Loves pizza
```

### 3. Memory Statistics

#### `get_memory_stats()`
Returns comprehensive statistics about stored memories.

**Returns:**
```ruby
{
  user_memories: 15,              # Count of persistent user memories
  session_memories: 8,            # Count of temporary session memories  
  total_memories: 23,             # Total memory count
  last_extraction: "2025-08-11T00:00:00Z"  # Last extraction timestamp
}
```

### 4. Memory Management

#### `clear_session_memories()`
Clears all session-specific memories.

**Example:**
```ruby
memory_service.clear_session_memories
# Deletes session memory file and logs action
```

#### `clear_user_memories()`
Clears all user-specific memories.

**Example:**
```ruby
memory_service.clear_user_memories
# Deletes user memory file and logs action
```

## Memory Data Structure

### Memory Object Format
```ruby
{
  "content" => "User's name is John",
  "category" => "personal_facts",
  "importance" => "high",
  "type" => "user",
  "timestamp" => "2025-08-11T00:00:00Z"
}
```

### Memory Categories
- `personal_facts`: Name, age, location, occupation, family
- `preferences`: Likes, dislikes, hobbies, interests  
- `goals`: Short-term and long-term objectives
- `events`: Important milestones or occurrences
- `skills`: Expertise and abilities
- `projects`: Current activities and work

### Importance Levels
- `high`: Critical information for personalization
- `medium`: Useful context information
- `low`: Background details

### Memory Types
- `user`: Persistent across all sessions
- `session`: Temporary, cleared when session ends

## Storage Format

### User Memory File Structure
```json
{
  "memories": [
    {
      "content": "User's name is John",
      "category": "personal_facts", 
      "importance": "high",
      "type": "user",
      "timestamp": "2025-08-11T00:00:00Z"
    }
  ],
  "last_updated": "2025-08-11T00:00:00Z"
}
```

### Session Memory File Structure
```json
{
  "memories": [
    {
      "content": "Currently discussing food preferences",
      "category": "events",
      "importance": "medium", 
      "type": "session",
      "timestamp": "2025-08-11T00:00:00Z"
    }
  ],
  "last_updated": "2025-08-11T00:00:00Z"
}
```

## Integration Patterns

### 1. Controller Integration
```ruby
class MessagesController < ApplicationController
  def generate_ai_response
    # Initialize memory service
    memory_service = Memory::OptimizedMemoryService.new(
      user_id: current_user_id,
      session_id: session.id
    )
    
    # Get conversation context
    chat_messages = prepare_chat_messages
    
    # Retrieve relevant memories
    memory_context = memory_service.get_relevant_memories_for_prompt(
      chat_messages.last&.dig(:content), 10
    )
    
    # Generate enhanced response
    enhanced_prompt = build_enhanced_system_prompt(memory_context)
    response = generate_ai_response_with_prompt(enhanced_prompt)
    
    # Store response and extract memories (background)
    save_response(response)
    memory_service.extract_and_store_memories(chat_messages, response)
  end
end
```

### 2. Memory Dashboard Integration
```ruby
class MemoriesController < ApplicationController
  def index
    memory_service = Memory::OptimizedMemoryService.new(
      user_id: current_user_id,
      session_id: session.id
    )
    
    @memory_stats = memory_service.get_memory_stats
    @user_memories = memory_service.send(:get_user_memories)
    @session_memories = memory_service.send(:get_session_memories)
  end
end
```

## Performance Characteristics

### Memory Limits
- **User Memories**: 100 memories maximum (most important retained)
- **Session Memories**: 30 memories maximum (most recent retained)
- **Extraction Cache**: In-memory cache to prevent duplicate processing

### Background Processing
- Memory extraction runs in separate threads
- Non-blocking operation ensures immediate chat responses
- Comprehensive error handling prevents thread crashes

### Deduplication Algorithm
- Similarity calculation using word overlap
- 70% similarity threshold for duplicate detection
- Importance-based retention for conflicting memories

## Error Handling

### Background Thread Errors
```ruby
begin
  # Memory extraction logic
rescue => e
  Rails.logger.error("Background memory extraction failed: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
  # Continues without affecting user experience
end
```

### File Operation Errors
```ruby
begin
  write_json_file(file_path, data)
rescue => e
  Rails.logger.error("Failed to write memory file #{file_path}: #{e.message}")
  return false
end
```

## Configuration Options

### Memory Extraction Prompt
The system uses an optimized extraction prompt that focuses on factual, actionable information:

```ruby
MEMORY_EXTRACTION_PROMPT = <<~PROMPT
  You are an intelligent memory extraction system. Analyze the conversation and extract only the most important, factual information that should be remembered.
  
  Extract memories in these categories ONLY if they contain significant information:
  1. Personal facts (name, age, location, occupation, family)
  2. Preferences and interests (likes, dislikes, hobbies)
  3. Goals and objectives (short-term and long-term)
  4. Important events or milestones
  5. Skills and expertise
  6. Current projects or activities
  
  Rules:
  - Extract only factual, specific information
  - Avoid generic or obvious statements
  - Focus on information that would be useful for future conversations
  - Each memory should be concise and actionable
  
  Return ONLY a JSON object with this structure:
  {
    "memories": [
      {
        "content": "specific factual information",
        "category": "personal_facts|preferences|goals|events|skills|projects",
        "importance": "high|medium|low",
        "type": "user|session"
      }
    ]
  }
  
  If no significant information is found, return: {"memories": []}
PROMPT
```

### Raix Configuration
```ruby
def chat_completion(params: {}, json: false, raw: false, openai: "gpt-3.5-turbo", save_response: false, messages: nil, available_tools: nil, max_tool_calls: 10)
  params[:max_completion_tokens] ||= 800
  params[:temperature] ||= 0.1
  
  super(params: params, json: json, raw: raw, openai: openai, save_response: save_response, messages: messages, available_tools: available_tools, max_tool_calls: max_tool_calls)
end
```

## Monitoring and Debugging

### Logging
The system provides comprehensive logging for monitoring:

```ruby
Rails.logger.info("Starting memory extraction for user: #{user_id}, session: #{session_id}")
Rails.logger.info("Stored #{user_memories.count} user memories, #{session_memories.count} session memories")
Rails.logger.error("Background memory extraction failed: #{e.message}")
```

### Memory File Locations
```
storage/memories/
├── user_[user_id].json      # User-specific memories
└── session_[session_id].json # Session-specific memories
```

### Debug Methods
```ruby
# Check memory counts
memory_service.send(:count_user_memories)
memory_service.send(:count_session_memories)

# View raw memory data
memory_service.send(:get_user_memories)
memory_service.send(:get_session_memories)
```

## Best Practices

### 1. **User ID Management**
- Use consistent user IDs across sessions
- For anonymous users, use session-based IDs: `"anonymous_#{session.id}"`

### 2. **Memory Context Usage**
- Limit memory retrieval to relevant context (10-15 memories max)
- Use query context for better relevance filtering

### 3. **Error Handling**
- Always wrap memory operations in try-catch blocks
- Provide fallback behavior when memory operations fail

### 4. **Performance Optimization**
- Use background processing for memory extraction
- Implement caching for frequently accessed memories
- Regular cleanup of old session memories

This API provides a robust, efficient foundation for implementing intelligent memory in AI chat applications.
