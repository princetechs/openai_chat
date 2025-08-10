require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chat = Chat.create!(title: "Test Chat")
  end

  test "should create message with clean response" do
    post chat_messages_path(@chat), params: {
      message: { content: "Hello, I'm testing the chat" }
    }
    
    assert_response :redirect
    assert_redirected_to chat_path(@chat)
    
    # Check that message was created
    user_message = @chat.messages.where(role: 'user').last
    assistant_message = @chat.messages.where(role: 'assistant').last
    
    assert_not_nil user_message
    assert_not_nil assistant_message
    assert_equal "Hello, I'm testing the chat", user_message.content
    
    # Assistant response should not contain JSON or memory artifacts
    assert_not_includes assistant_message.content, '"response"'
    assert_not_includes assistant_message.content, '"memory_update"'
    assert_not_includes assistant_message.content, 'category'
  end
  
  test "parse_ai_response extracts clean response" do
    controller = MessagesController.new
    
    # Test with clean response
    result = controller.send(:parse_ai_response, "Hello! How can I help you?")
    assert_equal "Hello! How can I help you?", result[:response]
    assert_nil result[:memory_data]
    assert_nil result[:debug_info]
  end
  
  test "parse_ai_response handles debug mode" do
    controller = MessagesController.new
    
    # Mock debug mode enabled
    allow(controller).to receive(:show_memory_debug?).and_return(true)
    
    result = controller.send(:parse_ai_response, "Test response")
    assert_equal "Test response", result[:response]
    assert_not_nil result[:debug_info]
    assert_includes result[:debug_info][:raw_content], "Test response"
  end
  
  test "show_memory_debug respects environment and params" do
    controller = MessagesController.new
    
    # Test with environment variable
    ENV['SHOW_MEMORY_DEBUG'] = 'true'
    assert controller.send(:show_memory_debug?)
    
    ENV['SHOW_MEMORY_DEBUG'] = 'false'
    refute controller.send(:show_memory_debug?)
    
    # Clean up
    ENV.delete('SHOW_MEMORY_DEBUG')
  end
end
