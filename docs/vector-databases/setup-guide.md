# Vector Database Setup Guide

## Overview
The optimized memory system supports multiple vector databases for enhanced semantic search and memory retrieval. This guide covers setup for Redis, PGVector, and Pinecone.

## Supported Vector Databases

### 1. Redis with Vector Search
**Best for**: Development, small to medium scale deployments

#### Installation
```bash
# Install Redis with RediSearch module
docker run -d --name redis-stack -p 6379:6379 redis/redis-stack:latest

# Or install locally (macOS)
brew install redis
```

#### Configuration
```bash
# Environment variables
export REDIS_VECTOR_ENABLED=true
export REDIS_URL=redis://localhost:6379
export REDIS_INDEX_NAME=memory_vectors
```

#### Gemfile
```ruby
gem 'redis', '~> 5.0'
```

### 2. PostgreSQL with PGVector
**Best for**: Production deployments, existing PostgreSQL infrastructure

#### Installation
```bash
# Install PostgreSQL with pgvector extension
# Ubuntu/Debian
sudo apt install postgresql-15-pgvector

# macOS with Homebrew
brew install pgvector

# Or use Docker
docker run -d --name postgres-vector \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  pgvector/pgvector:pg15
```

#### Database Setup
```sql
-- Connect to your database and enable the extension
CREATE EXTENSION IF NOT EXISTS vector;

-- The table will be created automatically by the service
```

#### Configuration
```bash
# Environment variables
export PGVECTOR_ENABLED=true
export PGVECTOR_TABLE=memory_embeddings
export DATABASE_URL=postgresql://user:password@localhost:5432/your_db
```

#### Gemfile
```ruby
gem 'pg', '~> 1.4'
# pgvector extension is included in the service
```

### 3. Pinecone
**Best for**: Large scale, managed vector database

#### Setup
1. Sign up at [Pinecone](https://www.pinecone.io/)
2. Create a new index with:
   - Dimensions: 1536 (for OpenAI embeddings)
   - Metric: cosine
   - Pod type: p1.x1 (starter)

#### Configuration
```bash
# Environment variables
export PINECONE_ENABLED=true
export PINECONE_API_KEY=your-api-key
export PINECONE_ENVIRONMENT=your-environment
export PINECONE_INDEX_NAME=memory-index
```

#### Gemfile
```ruby
gem 'pinecone', '~> 0.1'
```

## Environment Configuration

### Complete .env Example
```bash
# OpenAI Configuration
OAI_ACCESS_TOKEN=your-openai-api-key

# Vector Database Selection (enable only one)
REDIS_VECTOR_ENABLED=true
# PGVECTOR_ENABLED=true
# PINECONE_ENABLED=true

# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_INDEX_NAME=memory_vectors

# PGVector Configuration
# PGVECTOR_TABLE=memory_embeddings

# Pinecone Configuration
# PINECONE_API_KEY=your-pinecone-api-key
# PINECONE_ENVIRONMENT=your-pinecone-environment
# PINECONE_INDEX_NAME=memory-index

# Embedding Configuration
EMBEDDING_MODEL=text-embedding-ada-002
EMBEDDING_DIMENSIONS=1536
```

## Installation Steps

### 1. Choose Your Vector Database
Select one vector database based on your needs:
- **Redis**: Quick setup, good for development
- **PGVector**: Production ready, integrates with existing PostgreSQL
- **Pinecone**: Managed service, scales automatically

### 2. Install Dependencies
```bash
# For Redis
bundle add redis

# For PGVector (if not already using PostgreSQL)
bundle add pg

# For Pinecone
bundle add pinecone
```

### 3. Configure Environment
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 4. Initialize Database (PGVector only)
```bash
# Run Rails console to create the table
rails console

# The table will be created automatically on first use
Memory::OptimizedMemoryService.new(user_id: 'test', session_id: 'test')
```

## Usage Examples

### Basic Usage
```ruby
# Initialize service (automatically detects vector DB)
memory_service = Memory::OptimizedMemoryService.new(
  user_id: current_user.id,
  session_id: session.id
)

# Search similar memories using vector similarity
similar_memories = memory_service.search_similar_memories(
  "What are my preferences?", 
  limit: 5
)

# Regular memory retrieval (fallback)
context_memories = memory_service.get_relevant_memories_for_prompt(
  query, 
  limit: 10
)
```

### Advanced Vector Search
```ruby
# Combine vector and keyword search
query = "technology preferences"
vector_results = memory_service.search_similar_memories(query, 5)
keyword_results = memory_service.get_relevant_memories_for_prompt(query, 5)

# Merge and deduplicate results
all_memories = (vector_results + keyword_results).uniq { |m| m['content'] }
best_matches = all_memories.first(10)
```

## Performance Considerations

### Redis
- **Memory Usage**: Stores all vectors in RAM
- **Search Speed**: Very fast (< 10ms)
- **Scalability**: Limited by available RAM
- **Best For**: < 100K memories

### PGVector
- **Storage**: Disk-based with intelligent caching
- **Search Speed**: Fast (10-50ms)
- **Scalability**: Excellent (millions of vectors)
- **Best For**: Production applications

### Pinecone
- **Storage**: Managed cloud storage
- **Search Speed**: Fast (20-100ms including network)
- **Scalability**: Unlimited
- **Best For**: Large scale applications

## Monitoring and Debugging

### Check Vector Database Status
```ruby
# In Rails console
memory_service = Memory::OptimizedMemoryService.new(user_id: 'test', session_id: 'test')

# Check if vector DB is enabled
puts memory_service.send(:vector_db_enabled?)

# Check which vector DB is active
config = Memory::OptimizedMemoryService::VECTOR_DB_CONFIG
config.each { |db, conf| puts "#{db}: #{conf[:enabled]}" }
```

### Performance Monitoring
```ruby
# Time vector search
start_time = Time.current
results = memory_service.search_similar_memories("test query", 5)
search_time = Time.current - start_time
puts "Vector search took: #{search_time}s"
```

### Logs
```bash
# Check Rails logs for vector database operations
tail -f log/development.log | grep -E "(Vector|Embedding|Redis|PGVector|Pinecone)"
```

## Troubleshooting

### Common Issues

#### Redis Connection Failed
```bash
# Check Redis is running
redis-cli ping

# Check connection
redis-cli -u $REDIS_URL ping
```

#### PGVector Extension Missing
```sql
-- Connect to database and check extensions
\dx

-- Install extension if missing
CREATE EXTENSION IF NOT EXISTS vector;
```

#### Pinecone API Errors
```bash
# Test API key
curl -X GET "https://controller.${PINECONE_ENVIRONMENT}.pinecone.io/databases" \
  -H "Api-Key: ${PINECONE_API_KEY}"
```

#### Embedding Generation Fails
- Check OpenAI API key is valid
- Verify API quota and billing
- Check text length (max 8192 tokens)

### Fallback Behavior
If vector database fails, the system automatically falls back to:
1. JSON file-based memory storage
2. Keyword-based memory retrieval
3. Standard memory context injection

## Migration from JSON-only Storage

### Existing Memory Migration
```ruby
# Rails console script to migrate existing memories to vector DB
memory_service = Memory::OptimizedMemoryService.new(user_id: 'user_id', session_id: 'session_id')

# Get existing memories
user_memories = memory_service.send(:get_user_memories)
session_memories = memory_service.send(:get_session_memories)

# Store in vector database
all_memories = user_memories + session_memories
memory_service.send(:store_in_vector_db, all_memories)

puts "Migrated #{all_memories.count} memories to vector database"
```

## Best Practices

### 1. **Database Selection**
- Use Redis for development and small deployments
- Use PGVector for production with existing PostgreSQL
- Use Pinecone for large scale or managed solutions

### 2. **Memory Management**
- Enable vector search for better semantic matching
- Keep JSON storage as backup/fallback
- Regular cleanup of old embeddings

### 3. **Performance Optimization**
- Batch embedding generation when possible
- Use appropriate vector dimensions (1536 for OpenAI)
- Monitor search latency and adjust limits

### 4. **Security**
- Secure vector database connections
- Encrypt sensitive memory content
- Regular backup of vector indexes

This setup provides a robust, scalable foundation for semantic memory search while maintaining backward compatibility with JSON storage.
