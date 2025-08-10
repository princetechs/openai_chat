class MessagesController < ApplicationController
  # Helper method for current user (since we don't have authentication yet)
  def current_user
    nil # Return nil for now, can be updated when authentication is added
  end
  # Define the constant once, at class level
  CLEAN_CHAT_SYSTEM_PROMPT = <<~PROMPT
    You are a helpful AI assistant. Respond naturally and conversationally to the user's messages.
    
    Guidelines:
    - Be helpful, friendly, and engaging
    - Provide accurate and relevant information
    - Use any provided memory context to personalize your responses
    - Respond ONLY with your conversational reply - no JSON, no metadata, no technical artifacts
    - Keep responses concise but informative
    
    Your response should be natural conversation only.
  PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.role = Message::ROLE_USER

    if @message.save
      generate_ai_response

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chat }
      end
    else
      redirect_to @chat, alert: 'Failed to send message.'
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def generate_ai_response
    begin
      # Create AI memory service
      memory_service = AiMemory::MemoryService.new(
        user_id: current_user&.id || session[:user_id] || "anonymous_#{session.id}",
        session_id: session.id
      )
      
      # Get chat messages for context
      chat_messages = @chat.messages.order(:created_at).map do |msg|
        { role: msg.role, content: msg.content }
      end
      
      # Get relevant memories for context
      last_message = chat_messages.last&.dig(:content)
      memories = memory_service.get_relevant_memories(
        query: last_message,
        limit: 10
      )
      memory_context = memory_service.format_memories_for_prompt(memories)
      
      # Enhanced system prompt with memory context
      enhanced_prompt = build_enhanced_system_prompt(memory_context)
      
      # Create chat assistant with enhanced prompt
      assistant = ChatAssistant.new(enhanced_prompt, chat_messages)
      
      # Generate response
      raw_content = assistant.chat_completion
      
      if raw_content.present?
        # Parse response to separate conversational content from memory data
        parsed_response = parse_ai_response(raw_content)
        display_content = parsed_response[:response]
        
        # Create assistant message with clean response only
        final_content = display_content
        
        # Add debug info if enabled (for developers only)
        if show_memory_debug? && parsed_response[:debug_info]
          final_content += "\n\n--- DEBUG INFO ---\n#{parsed_response[:debug_info].to_json}"
        end
        
        @chat.messages.create(
          content: final_content,
          role: Message::ROLE_ASSISTANT
        )
        
        # Extract and store memories in background (completely silent)
        Thread.new do
          begin
            full_conversation = chat_messages + [{ role: 'assistant', content: display_content }]
            memory_service.extract_and_store_memories(full_conversation, display_content)
          rescue => e
            Rails.logger.error("Background memory extraction error: #{e.message}")
          end
        end
      else
        @chat.messages.create(
          content: "I'm sorry, I couldn't generate a response at this time.",
          role: Message::ROLE_ASSISTANT
        )
      end
    rescue => e
      Rails.logger.error("Optimized chat error: #{e.message}")
      @chat.messages.create(
        content: "I'm sorry, there was an error processing your request. Please try again later.",
        role: Message::ROLE_ASSISTANT
      )
    end
  end
  
  private
  
  def parse_ai_response(raw_content)
    # Since we're using clean chat prompt, the response should be pure conversational content
    # Add debug info if requested by developers
    {
      response: raw_content.strip,
      memory_data: nil,
      debug_info: show_memory_debug? ? { raw_content: raw_content, timestamp: Time.current } : nil
    }
  end
  
  def show_memory_debug?
    # Enable memory debug mode via parameter or environment
    params[:show_memory_response] == 'true' || 
    Rails.env.development? && ENV['SHOW_MEMORY_DEBUG'] == 'true'
  end
  
  def build_enhanced_system_prompt(memory_context)
    base_prompt = CLEAN_CHAT_SYSTEM_PROMPT
    
    if memory_context.present?
      <<~ENHANCED_PROMPT
        #{base_prompt}
        
        #{memory_context}
        
        Use this context to provide personalized responses. Reference relevant memories naturally without explicitly mentioning that you're using stored information.
      ENHANCED_PROMPT
    else
      base_prompt
    end
  end
end
