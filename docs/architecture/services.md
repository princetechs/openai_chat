# Service Layer Architecture

## Overview
The application follows Rails service object patterns to maintain clean, modular, and testable code. All memory-related operations are encapsulated in dedicated service classes.

## Service Hierarchy

### Base Service
```ruby
# app/services/memory/base_memory_service.rb
module Memory
  class BaseMemoryService
    # Foundation class providing:
    # - File system operations
    # - JSON parsing/writing
    # - Storage directory management
    # - Common utilities
  end
end
```

### Core Services

#### 1. Memory Extraction Service
```ruby
# app/services/memory/memory_extraction_service.rb
class MemoryExtractionService < BaseMemoryService
  include Raix::ChatCompletion
  
  # Responsibilities:
  # - Analyze conversations using AI
  # - Extract meaningful memories
  # - Categorize and score importance
  # - Return structured memory data
end
```

**Key Methods:**
- `extract_memories_from_conversation(messages)` - Main extraction logic
- `format_conversation(messages)` - Prepare conversation for analysis
- `validate_memory_response(response)` - Ensure proper JSON structure

#### 2. Memory Storage Service
```ruby
# app/services/memory/memory_storage_service.rb
class MemoryStorageService < BaseMemoryService
  
  # Responsibilities:
  # - Store/retrieve memories from JSON files
  # - Handle deduplication
  # - Manage memory limits
  # - Provide search functionality
end
```

**Key Methods:**
- `store_memories(extracted_memories)` - Save memories to files
- `retrieve_relevant_memories(query_context)` - Get contextual memories
- `get_memory_summary_for_prompt()` - Format for AI prompts

#### 3. Memory Enhanced Chat Service
```ruby
# app/services/memory/memory_enhanced_chat_service.rb
class MemoryEnhancedChatService < BaseMemoryService
  include Raix::ChatCompletion
  
  # Responsibilities:
  # - Generate AI responses with memory context
  # - Coordinate memory extraction and storage
  # - Enhance system prompts with memories
  # - Handle chat completion with Raix
end
```

**Key Methods:**
- `generate_response_with_memory(system_prompt)` - Main chat logic
- `build_enhanced_system_prompt(original, memory_context)` - Prompt enhancement
- `extract_and_store_memories(messages, response)` - Post-response processing

#### 4. Memory Manager Service
```ruby
# app/services/memory/memory_manager_service.rb
class MemoryManagerService < BaseMemoryService
  
  # Responsibilities:
  # - Provide management interface
  # - Generate statistics and analytics
  # - Handle import/export operations
  # - Search and filter memories
end
```

**Key Methods:**
- `get_memory_dashboard()` - Dashboard data
- `search_memories(query)` - Search functionality
- `export_memories()` - Data export
- `clear_user_memories()` - Cleanup operations

## Service Integration Pattern

### Controller Integration
```ruby
class MessagesController < ApplicationController
  def generate_ai_response
    # Single service call handles entire memory-enhanced chat flow
    memory_chat_service = ::Memory::MemoryEnhancedChatService.new(
      user_id: current_user&.id || "anonymous_#{session.id}",
      session_id: session.id,
      chat: @chat
    )
    
    response = memory_chat_service.generate_response_with_memory(SYSTEM_PROMPT)
  end
end
```

### Service Composition
Services are composed rather than inherited, allowing for:
- **Single Responsibility**: Each service has one clear purpose
- **Dependency Injection**: Services can be easily tested and mocked
- **Loose Coupling**: Changes in one service don't affect others
- **Reusability**: Services can be used in different contexts

## Error Handling Strategy

### Graceful Degradation
```ruby
begin
  # Memory-enhanced response
  response = memory_chat_service.generate_response_with_memory(prompt)
rescue => e
  Rails.logger.error("Memory system error: #{e.message}")
  # Fallback to basic response
  response = basic_chat_response(prompt)
end
```

### Logging and Monitoring
- All services log important operations
- Errors are captured with context
- Performance metrics can be added easily
- Memory extraction success rates tracked

## Testing Strategy

### Service Testing
```ruby
# Example test structure
RSpec.describe Memory::MemoryExtractionService do
  let(:service) { described_class.new(user_id: 'test', session_id: 'session') }
  
  describe '#extract_memories_from_conversation' do
    it 'extracts user preferences from conversation'
    it 'handles malformed AI responses gracefully'
    it 'categorizes memories correctly'
  end
end
```

### Integration Testing
- Test service interactions
- Verify memory persistence
- Check prompt enhancement
- Validate error handling

## Performance Considerations

### Optimization Strategies
- **Lazy Loading**: Load memories only when needed
- **Caching**: Cache frequently accessed memories
- **Async Processing**: Extract memories in background jobs
- **File Optimization**: Compress large memory files

### Monitoring Points
- Memory extraction time
- File I/O operations
- Memory file sizes
- API response times

## Extension Points

### Adding New Memory Types
1. Extend extraction prompt with new categories
2. Update storage schema if needed
3. Add specific handling in storage service
4. Update dashboard display logic

### Custom Memory Providers
```ruby
# Example: Database-backed memory storage
class DatabaseMemoryStorage < BaseMemoryService
  # Implement same interface as file-based storage
  # But use ActiveRecord models instead
end
```

## Best Practices

### Service Design
- Keep services focused on single responsibility
- Use dependency injection for testability
- Handle errors gracefully with fallbacks
- Log important operations and errors
- Follow Rails naming conventions

### Memory Management
- Set reasonable limits on memory storage
- Implement cleanup strategies
- Validate data before storage
- Provide user control over their data
- Consider privacy implications

## Next Steps
- [Memory System Design](memory-design.md)
- [Database Schema](database.md)
- [API Documentation](../api/endpoints.md)
