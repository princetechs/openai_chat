# Example Environment Configuration for Vector Memory System
# Copy this file to .env or set these environment variables

# ================================
# REQUIRED: OpenAI Configuration
# ================================
# OAI_ACCESS_TOKEN=your-openai-api-key-here

# ================================
# VECTOR DATABASE CONFIGURATION
# Enable only ONE vector database
# ================================

# Option 1: Redis Vector (Recommended for Development)
# REDIS_VECTOR_ENABLED=true
# REDIS_URL=redis://localhost:6379
# REDIS_INDEX_NAME=memory_vectors

# Option 2: PostgreSQL with PGVector (Recommended for Production)
# PGVECTOR_ENABLED=true
# PGVECTOR_TABLE=memory_embeddings
# DATABASE_URL=postgresql://user:password@localhost:5432/your_database

# Option 3: Pinecone (Managed Vector Database)
# PINECONE_ENABLED=true
# PINECONE_API_KEY=your-pinecone-api-key
# PINECONE_ENVIRONMENT=your-pinecone-environment
# PINECONE_INDEX_NAME=memory-index

# ================================
# EMBEDDING CONFIGURATION
# ================================
# EMBEDDING_MODEL=text-embedding-ada-002
# EMBEDDING_DIMENSIONS=1536

# ================================
# RAILS CONFIGURATION
# ================================
# RAILS_ENV=development
# SECRET_KEY_BASE=your-secret-key-base
