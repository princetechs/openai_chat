class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :edit, :update, :destroy]

  def index
    @chats = Chat.all.order(created_at: :desc)
  end

  def show
    # Filter out system messages for display but keep them for context
    @messages = @chat.messages.where.not(role: Message::ROLE_SYSTEM).order(:created_at)
    @message = Message.new
    
    # Set page title to chat title
    @page_title = @chat.title
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(chat_params)

    if @chat.save
      # Create a system message to set the context for the chat
      @chat.messages.create(content: 'You are a helpful assistant.', role: Message::ROLE_SYSTEM)
      redirect_to @chat, notice: 'Chat was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @chat.update(chat_params)
      redirect_to @chat, notice: 'Chat was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chat.destroy
    redirect_to chats_path, notice: 'Chat was successfully deleted.'
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title)
  end
end
