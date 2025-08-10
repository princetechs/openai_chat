class ChatAssistant
  include Raix::ChatCompletion
  
  # Initialize with system prompt and existing messages
  def initialize(system_prompt, messages = [])
    @transcript = []
    
    # Add system prompt if provided
    @transcript << { system: system_prompt } if system_prompt.present?
    
    # Add existing messages
    messages.each do |msg|
      @transcript << { msg[:role].to_sym => msg[:content] }
    end
  end
  
  # Override to set appropriate parameters for chat
  def chat_completion(params: {}, json: false, raw: false, openai: "gpt-3.5-turbo", save_response: true, messages: nil, available_tools: nil, max_tool_calls: 10)
    # Set appropriate max_completion_tokens for GPT-3.5-turbo
    params[:max_completion_tokens] = 500
    params[:temperature] = 0.7
    
    # Call the parent method with the openai parameter explicitly set
    super(params: params, json: json, raw: raw, openai: openai, save_response: save_response, messages: messages, available_tools: available_tools, max_tool_calls: max_tool_calls)
  end
  
  # Access to transcript
  def transcript
    @transcript ||= []
  end
end
