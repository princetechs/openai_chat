# Memory System Overview

## Introduction
The memory system provides stateful AI conversations by automatically extracting, storing, and utilizing contextual information from chat interactions.

## Architecture

### Two-Tier Memory System
1. **User Memories**: Persistent across all sessions
   - Personal preferences and details
   - Long-term context and relationships
   - Skills, expertise, and interests
   - Maximum: 200 memories per user

2. **Session Memories**: Temporary conversation context
   - Current conversation topics
   - Immediate context and references
   - Emotional state and mood
   - Maximum: 50 memories per session

## Core Components

### Service Layer
```
app/services/memory/
├── base_memory_service.rb          # Foundation class
├── memory_extraction_service.rb    # AI-powered extraction
├── memory_storage_service.rb       # File operations
├── memory_enhanced_chat_service.rb # Main chat integration
└── memory_manager_service.rb       # Management operations
```

### Storage System
```
storage/memories/
├── user_[user_id].json    # Persistent user memories
└── session_[session_id].json # Temporary session memories
```

## Memory Extraction Process

### 1. Conversation Analysis
After each AI response, the system:
- Analyzes the full conversation context
- Uses specialized LLM prompts for extraction
- Identifies important information to remember

### 2. Categorization
Memories are categorized by:
- **Category**: Type of information (preferences, personal_details, etc.)
- **Importance**: High, Medium, Low priority
- **Timestamp**: When the memory was created
- **Content**: The actual information to remember

### 3. Storage & Deduplication
- Prevents duplicate memories
- Updates existing memories with new information
- Maintains importance-based retention
- Automatic cleanup of old/irrelevant memories

## Memory Integration

### Enhanced Prompts
Before generating responses, the system:
1. Retrieves relevant memories
2. Enhances system prompts with context
3. Provides personalized, consistent responses

### Example Enhanced Prompt
```
You are a helpful AI assistant...

=== MEMORY CONTEXT ===
User Profile:
- Name: Sandip
- Interests: AI development, Ruby on Rails
- Current project: Chat application with memory

Current Session Context:
- Working on memory system implementation
- Experiencing namespace errors
- Requested documentation structure
```

## Key Features

### Automatic Memory Management
- **Smart Deduplication**: Prevents storing similar information
- **Importance Scoring**: Prioritizes valuable memories
- **Age-based Cleanup**: Removes outdated information
- **Category Organization**: Groups related memories

### Memory Dashboard
- Visual interface at `/memories`
- View all stored memories
- Search and filter capabilities
- Export/import functionality
- Clear session or user memories

### API Integration
- RESTful endpoints for memory operations
- JSON format for data exchange
- Real-time memory updates
- Statistics and analytics

## Benefits

### For Users
- **Personalized Conversations**: AI remembers preferences and context
- **Consistent Interactions**: No need to repeat information
- **Progressive Learning**: AI understanding improves over time
- **Privacy Control**: Manage what's remembered

### For Developers
- **Modular Design**: Clean service architecture
- **Extensible System**: Easy to add new memory types
- **Rails Conventions**: Follows Rails best practices
- **Error Handling**: Graceful fallbacks for failures

## Memory Types Examples

### User Memories
```json
{
  "category": "personal_details",
  "content": "User's name is Sandip, works on AI projects",
  "importance": "high",
  "timestamp": "2025-08-10T18:00:00Z"
}
```

### Session Memories
```json
{
  "category": "current_task",
  "content": "Working on fixing namespace errors in memory system",
  "importance": "medium",
  "timestamp": "2025-08-10T18:30:00Z"
}
```

## Next Steps
- [Memory Types Details](types.md)
- [Extraction Process](extraction.md)
- [Storage Format](storage.md)
- [Management Features](management.md)
