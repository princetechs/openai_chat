require 'test_helper'

class AiMemoryIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @memory_service = AiMemory::MemoryService.new(
      user_id: 'test_user',
      session_id: 'test_session'
    )
  end

  test "memory service initializes correctly" do
    assert_not_nil @memory_service
    stats = @memory_service.get_memory_stats
    assert_equal 0, stats[:user_memories]
    assert_equal 0, stats[:session_memories]
  end

  test "memory service can store and retrieve memories" do
    # Test memory extraction and storage
    conversation = [
      { role: 'user', content: 'Hi, my name is John and I love pizza' },
      { role: 'assistant', content: 'Nice to meet you John! Pizza is delicious.' }
    ]

    # Extract memories (this would normally be async)
    @memory_service.extract_and_store_memories(conversation, 'Nice to meet you John!')
    
    # Allow some time for processing
    sleep(0.1)
    
    # Check that memories can be retrieved
    memories = @memory_service.get_relevant_memories(query: 'pizza', limit: 5)
    assert_kind_of Array, memories
  end

  test "memories controller index works with ai_memory gem" do
    get memories_path
    assert_response :success
    assert_select 'h1', 'Memory Dashboard'
  end

  test "memories controller can clear memories" do
    # Test clearing session memories via AJAX
    delete clear_session_memories_path, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal 'success', response_data['status']
  end
  
  test "memories controller redirects on HTML clear" do
    # Test clearing via HTML request (should redirect)
    delete clear_session_memories_path
    assert_response :redirect
    assert_redirected_to memories_path
  end

  test "memory configuration is properly loaded" do
    config = AiMemory.configuration
    assert_not_nil config.openai_api_key
    assert_not_nil config.storage_path
    assert_equal 100, config.max_user_memories
    assert_equal 30, config.max_session_memories
  end

  test "memory service handles errors gracefully" do
    # Test with invalid conversation data
    assert_nothing_raised do
      @memory_service.extract_and_store_memories([], '')
    end
  end

  test "vector database configuration" do
    config = AiMemory.configuration
    
    # Test that vector DB config is loaded
    assert_not_nil config.redis_enabled
    assert_not_nil config.pgvector_enabled
    assert_not_nil config.pinecone_enabled
    
    # At least one should be configurable
    assert [config.redis_enabled, config.pgvector_enabled, config.pinecone_enabled].any? { |v| v.is_a?(TrueClass) || v.is_a?(FalseClass) }
  end
end
