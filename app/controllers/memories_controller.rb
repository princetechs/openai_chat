class MemoriesController < ApplicationController
  before_action :set_memory_service
  
  # Helper method for current user (since we don't have authentication yet)
  def current_user
    nil # Return nil for now, can be updated when authentication is added
  end
  
  def index
    @memory_stats = @memory_service.get_memory_stats
    @user_memories = @memory_service.get_user_memories
    @session_memories = @memory_service.get_session_memories
    
    respond_to do |format|
      format.html
      format.json { render json: { stats: @memory_stats, user_memories: @user_memories, session_memories: @session_memories } }
    end
  end
  
  def show
    memories = {
      user_memories: @memory_service.get_user_memories,
      session_memories: @memory_service.get_session_memories,
      stats: @memory_service.get_memory_stats
    }
    
    respond_to do |format|
      format.json { render json: memories }
    end
  end
  
  def search
    query = params[:q]
    
    if query.present?
      @search_results = @memory_manager.search_memories(query)
    else
      @search_results = { user_memories: [], session_memories: [] }
    end
    
    respond_to do |format|
      format.json { render json: @search_results }
    end
  end
  
  def statistics
    @stats = @memory_manager.get_memory_statistics
    
    respond_to do |format|
      format.json { render json: @stats }
    end
  end
  
  def export
    @exported_memories = @memory_manager.export_memories
    
    respond_to do |format|
      format.json do 
        render json: @exported_memories
      end
      format.html do
        send_data @exported_memories.to_json, 
                  filename: "memories_#{current_user_id}_#{Date.current}.json",
                  type: 'application/json'
      end
    end
  end
  
  def import
    if params[:memory_file].present?
      begin
        memory_data = JSON.parse(params[:memory_file].read)
        
        if @memory_manager.import_memories(memory_data)
          flash[:notice] = "Memories imported successfully!"
        else
          flash[:alert] = "Failed to import memories. Please check the file format."
        end
      rescue JSON::ParserError
        flash[:alert] = "Invalid JSON file format."
      rescue => e
        Rails.logger.error("Memory import error: #{e.message}")
        flash[:alert] = "An error occurred while importing memories."
      end
    else
      flash[:alert] = "Please select a file to import."
    end
    
    redirect_to memories_path
  end
  
  def clear_session
    @memory_service.clear_memories(type: 'session')
    
    respond_to do |format|
      format.json { render json: { status: 'success', message: 'Session memories cleared' } }
      format.html do
        flash[:notice] = "Session memories cleared successfully!"
        redirect_to memories_path
      end
    end
  end
  
  def clear_user
    @memory_service.clear_memories(type: 'user')
    
    respond_to do |format|
      format.json { render json: { status: 'success', message: 'User memories cleared' } }
      format.html do
        flash[:notice] = "User memories cleared successfully!"
        redirect_to memories_path
      end
    end
  end
  
  private
  
  def set_memory_service
    @memory_service = AiMemory::MemoryService.new(
      user_id: current_user_id,
      session_id: session.id
    )
  end
  
  def current_user_id
    current_user&.id || session[:user_id] || "anonymous_#{session.id}"
  end
end
