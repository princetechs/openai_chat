# Rails AI Memory Integration Guide

This document explains how the AiMemory gem has been integrated into the Rails AI chat application.

## Integration Overview

The Rails application now uses the **AiMemory gem** instead of the legacy memory services, providing:
- ✅ **Silent memory extraction** - No more memory responses in chat
- ✅ **Vector database support** - Semantic search capabilities  
- ✅ **Non-blocking processing** - Background memory extraction
- ✅ **Modular architecture** - Clean, extensible gem structure

## What Was Changed

### 1. Gemfile Updates
```ruby
# Added AiMemory gem
gem 'ai_memory', path: '../ai_memory'
```

### 2. Configuration
- **Added:** `config/initializers/ai_memory.rb` - Gem configuration
- **Removed:** `config/initializers/vector_memory.rb` - Legacy config

### 3. Controllers Updated

**MessagesController:**
- Replaced `::Memory::OptimizedMemoryService` with `AiMemory::MemoryService`
- Updated memory retrieval to use `get_relevant_memories(query:, limit:)`
- Enhanced background memory extraction with proper error handling

**MemoriesController:**
- Updated to use `AiMemory::MemoryService` API
- Added public methods: `get_user_memories`, `get_session_memories`
- Updated clear methods to use `clear_memories(type:)`

### 4. Legacy Code Removed
- ✅ `app/services/memory/optimized_memory_service.rb`
- ✅ `app/services/memory/base_memory_service.rb`
- ✅ `app/services/memory/` directory
- ✅ `config/initializers/vector_memory.rb`

## Key Features

### Silent Memory Extraction
```ruby
# Memory extraction now happens in isolated background thread
Thread.new do
  begin
    full_conversation = chat_messages + [{ role: 'assistant', content: content }]
    memory_service.extract_and_store_memories(full_conversation, content)
  rescue => e
    Rails.logger.error("Background memory extraction error: #{e.message}")
  end
end
```

### Vector Database Support
The gem supports multiple vector databases:
- **Redis** with RediSearch
- **PostgreSQL** with PGVector extension
- **Pinecone** managed vector database

Configure via environment variables:
```bash
# Redis
REDIS_VECTOR_ENABLED=true
REDIS_URL=redis://localhost:6379

# PGVector  
PGVECTOR_ENABLED=true
DATABASE_URL=postgresql://user:pass@localhost/db

# Pinecone
PINECONE_ENABLED=true
PINECONE_API_KEY=your-key
PINECONE_ENVIRONMENT=your-env
```

### Memory Retrieval
```ruby
# Get contextual memories for AI prompts
memories = memory_service.get_relevant_memories(
  query: user_message,
  limit: 10
)

# Format for AI context
context = memory_service.format_memories_for_prompt(memories)
```

## Testing

### Integration Tests
- Created `test/integration/ai_memory_integration_test.rb`
- Tests memory service initialization, storage, retrieval
- Tests controller integration and error handling
- Tests configuration loading and vector DB setup

### Running Tests
```bash
# Run integration tests
rails test test/integration/ai_memory_integration_test.rb

# Run all tests
rails test
```

## Configuration Options

### Storage Settings
```ruby
config.storage_path = Rails.root.join("storage", "memories").to_s
config.max_user_memories = 100
config.max_session_memories = 30
config.similarity_threshold = 0.7
```

### AI Settings
```ruby
config.openai_api_key = ENV['OAI_ACCESS_TOKEN']
config.embedding_model = "text-embedding-ada-002"
config.embedding_dimensions = 1536
config.extraction_temperature = 0.1
config.extraction_max_tokens = 800
```

## Performance Benefits

1. **Non-blocking:** Memory extraction doesn't delay chat responses
2. **Efficient:** Vector search provides faster memory retrieval
3. **Scalable:** Configurable memory limits prevent storage bloat
4. **Robust:** Error handling prevents memory issues from breaking chat

## Monitoring

Check memory system status:
```ruby
# In Rails console
memory_service = AiMemory::MemoryService.new(user_id: 'test', session_id: 'test')
puts memory_service.get_memory_stats
```

## Troubleshooting

### Common Issues

1. **Memory extraction visible in chat:**
   - Ensure background thread isolation
   - Check for synchronous extraction calls

2. **Vector database not working:**
   - Verify environment variables
   - Check database connectivity
   - Review logs for connection errors

3. **Memory not persisting:**
   - Check storage directory permissions
   - Verify JSON file creation
   - Review extraction prompts

### Logs
Memory operations are logged to Rails logger:
```bash
tail -f log/development.log | grep "AiMemory"
```

## Next Steps

1. **Enable Vector Search:** Set up Redis/PGVector/Pinecone for semantic search
2. **Monitor Performance:** Track memory extraction times and storage usage
3. **Customize Extraction:** Adjust prompts and thresholds for your use case
4. **Scale Storage:** Consider database storage for high-volume applications

The integration is now complete and provides a robust, scalable memory system for your AI chat application.
