# API Endpoints Documentation

## Chat Endpoints

### Create Message
```
POST /chats/:chat_id/messages
```

**Parameters:**
```json
{
  "message": {
    "content": "User message content"
  }
}
```

**Response:**
- Creates user message
- Triggers AI response with memory enhancement
- Returns Turbo Stream for real-time updates

## Memory Management Endpoints

### Memory Dashboard
```
GET /memories
```
**Response:** HTML dashboard or JSON memory data

### Search Memories
```
GET /memories/search?q=query
```

**Parameters:**
- `q` (string): Search query

**Response:**
```json
{
  "user_memories": [...],
  "session_memories": [...]
}
```

### Memory Statistics
```
GET /memories/statistics
```

**Response:**
```json
{
  "total_user_memories": 15,
  "total_session_memories": 8,
  "user_memory_categories": {
    "personal_details": 5,
    "preferences": 3,
    "goals": 2
  },
  "memory_importance_distribution": {
    "user": {"high": 3, "medium": 8, "low": 4},
    "session": {"high": 1, "medium": 5, "low": 2}
  }
}
```

### Export Memories
```
GET /memories/export
```

**Formats:**
- `GET /memories/export.json` - JSON response
- `GET /memories/export` - File download

**Response:**
```json
{
  "user_id": "anonymous_session123",
  "session_id": "session123",
  "exported_at": "2025-08-10T18:00:00Z",
  "user_memories": [...],
  "session_memories": [...]
}
```

### Import Memories
```
POST /memories/import
```

**Parameters:**
- `memory_file` (file): JSON file with memory data

### Clear Session Memories
```
DELETE /memories/clear_session
```

**Response:**
```json
{
  "status": "success",
  "message": "Session memories cleared"
}
```

### Clear User Memories
```
DELETE /memories/clear_user
```

**Response:**
```json
{
  "status": "success", 
  "message": "User memories cleared"
}
```

## Memory Data Format

### Memory Object Structure
```json
{
  "category": "personal_details",
  "content": "User's name is Sandip, works on AI projects",
  "importance": "high",
  "timestamp": "2025-08-10T18:00:00Z"
}
```

### Memory Categories
- `personal_details` - Name, age, location, occupation
- `preferences` - Likes, dislikes, interests
- `goals` - Objectives and aspirations
- `emotional_context` - Mood and feelings
- `current_task` - Immediate activities
- `skills` - Expertise and abilities
- `relationships` - Connections and contacts

### Importance Levels
- `high` - Critical information for personalization
- `medium` - Useful context information
- `low` - Background details

## Error Responses

### Standard Error Format
```json
{
  "status": "error",
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

### Common Error Codes
- `MEMORY_EXTRACTION_FAILED` - AI memory extraction error
- `STORAGE_ERROR` - File system operation failed
- `INVALID_FORMAT` - Malformed request data
- `RATE_LIMIT_EXCEEDED` - API rate limit hit
