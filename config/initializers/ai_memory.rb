# AiMemory Configuration
# Configure the AI Memory system for your application

AiMemory.configure do |config|
  # Storage configuration
  config.storage_path = Rails.root.join("storage", "memories").to_s
  config.max_user_memories = 100
  config.max_session_memories = 30
  config.similarity_threshold = 0.7
  
  # OpenAI configuration
  config.openai_api_key = ENV['OAI_ACCESS_TOKEN'] || ENV['OPENAI_API_KEY']
  config.embedding_model = "text-embedding-ada-002"
  config.embedding_dimensions = 1536
  config.extraction_temperature = 0.1
  config.extraction_max_tokens = 800
  
  # Vector database configuration (enable only one)
  
  # Redis Vector Search
  config.redis_enabled = ENV['REDIS_VECTOR_ENABLED'] == 'true'
  config.redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379'
  config.redis_index_name = ENV['REDIS_INDEX_NAME'] || 'memory_vectors'
  
  # PostgreSQL with PGVector
  config.pgvector_enabled = ENV['PGVECTOR_ENABLED'] == 'true'
  config.pgvector_table_name = ENV['PGVECTOR_TABLE'] || 'memory_embeddings'
  
  # Pinecone
  config.pinecone_enabled = ENV['PINECONE_ENABLED'] == 'true'
  config.pinecone_api_key = ENV['PINECONE_API_KEY']
  config.pinecone_environment = ENV['PINECONE_ENVIRONMENT']
  config.pinecone_index_name = ENV['PINECONE_INDEX_NAME'] || 'memory-index'
  
  # Logger
  config.logger = Rails.logger
end
