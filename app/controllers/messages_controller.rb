class MessagesController < ApplicationController
  def current_user
    nil # placeholder until authentication
  end

  SYSTEM_PROMPT = <<~PROMPT
    You are a helpful AI assistant with memory capabilities.
    Respond naturally to the user and extract factual, specific information for memory storage.

    RULES:
    - Friendly, concise, informative.
    - Personalize using provided memory context.
    - Output must be a single valid JSON object:
      {"response":"<assistant reply>","memories":[{"content":"<fact>","category":"personal_facts|preferences|goals|events|skills|projects|name|friends|family","importance":"high|medium|low","type":"user|session"}]}
    - If no memories: {"response":"<assistant reply>","memories":[]}
    - No text before/after JSON. No markdown.
  PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params.merge(role: Message::ROLE_USER))

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
      memory_service = AiMemory::MemoryService.new(
        user_id: current_user&.id || session[:user_id] || "anonymous_#{session.id}",
        session_id: session.id
      )

      # Prepare chat history
      chat_messages = @chat.messages.order(:created_at).map { |m| { role: m.role, content: m.content } }
      last_message  = chat_messages.last&.dig(:content)

      # Get relevant memory context
      memory_context = memory_service.format_memories_for_prompt(
        memory_service.get_relevant_memories(query: last_message, limit: 10)
      )

      # Build assistant
      assistant = ChatAssistant.new(build_system_prompt(memory_context), chat_messages)

      # Request with json_object format
      raw_content = assistant.chat_completion(
        params: {
          response_format: { type: "json_object" }
        }
      )

      handle_ai_response(raw_content, memory_service)
    rescue => e
      Rails.logger.error("Chat error: #{e.message}")
      @chat.messages.create(
        content: "I'm sorry, something went wrong. Please try again later.",
        role: Message::ROLE_ASSISTANT
      )
    end
  end

  def handle_ai_response(raw_content, memory_service)
    unless raw_content.present?
      return @chat.messages.create(
        content: "I'm sorry, I couldn't generate a response right now.",
        role: Message::ROLE_ASSISTANT
      )
    end

    parsed = parse_ai_response(raw_content)

    # Save assistant's main reply
    @chat.messages.create(content: parsed[:response], role: Message::ROLE_ASSISTANT)

    # Store any memories
    if parsed[:memory_data].present?
      memory_service.store_memories(parsed[:memory_data])
      Rails.logger.info("Stored #{parsed[:memory_data].size} memories")

      if show_memory_debug?
        Rails.logger.debug("MEMORY DEBUG: #{parsed[:memory_data].to_json}")
        # Uncomment to show in frontend:
        # @chat.messages.create(content: "--- DEBUG ---\n#{parsed[:memory_data].to_json}", role: Message::ROLE_SYSTEM)
      end
    end
  end

  def parse_ai_response(raw)
    parsed = JSON.parse(raw.strip)
    {
      response: parsed['response'],
      memory_data: parsed['memories']
    }
  rescue JSON::ParserError => e
    Rails.logger.error("JSON parsing failed: #{e.message}")
    { response: raw.strip, memory_data: nil }
  end

  def build_system_prompt(memory_context)
    if memory_context.present?
      <<~PROMPT
        #{SYSTEM_PROMPT}

        MEMORY CONTEXT:
        #{memory_context}
      PROMPT
    else
      SYSTEM_PROMPT
    end
  end

  def show_memory_debug?
    params[:debug] == 'true' || (Rails.env.development? && ENV['SHOW_MEMORY_DEBUG'] == 'true')
  end
end
