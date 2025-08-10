class MeaningOfLife
  include Raix::ChatCompletion
  
  # Override the chat_completion method to explicitly use OpenAI
  def chat_completion(params: {}, json: false, raw: false, openai: "gpt-3.5-turbo", save_response: true, messages: nil, available_tools: nil, max_tool_calls: 10)
    # Set appropriate max_completion_tokens for GPT-3.5-turbo (4096 max)
    params[:max_completion_tokens] = 4000
    
    # Call the parent method with the openai parameter explicitly set
    super(params: params, json: json, raw: raw, openai: openai, save_response: save_response, messages: messages, available_tools: available_tools, max_tool_calls: max_tool_calls)
  end
end
