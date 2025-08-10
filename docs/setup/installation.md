# Installation Guide

## Prerequisites
- Ruby 3.4.3 (or compatible version)
- Rails 7.2.2+
- Node.js and Yarn
- SQLite3

## Installation Steps

### 1. Clone and Setup
```bash
cd /Users/sandip/personal/rubylm/openai_chat
bundle install
yarn install
```

### 2. Database Setup
```bash
rails db:create
rails db:migrate
```

### 3. Environment Configuration
Create a `.env` file in the root directory:
```bash
# OpenAI Configuration
OAI_ACCESS_TOKEN=your_openai_api_key_here

# Optional: OpenRouter Configuration (currently disabled)
# OR_ACCESS_TOKEN=your_openrouter_api_key_here
```

### 4. Memory Storage Setup
The application will automatically create the memory storage directory:
```
storage/memories/
```

### 5. Start the Application
```bash
rails server
```

The application will be available at `http://localhost:3000`

## Verification

### Test Basic Chat
1. Visit `http://localhost:3000`
2. Create a new chat
3. Send a message
4. Verify AI response

### Test Memory System
1. Have a conversation mentioning personal details
2. Visit `/memories` to see extracted memories
3. Continue conversation to see contextual responses

## Troubleshooting

### Common Issues
- **Faraday retry errors**: Ensure `faraday-retry` gem is installed
- **OpenAI API errors**: Check your API key and token limits
- **Memory extraction failures**: Check logs for JSON parsing errors

### Required Gems
The following gems are essential for the memory system:
```ruby
gem 'raix', '~> 1.0'
gem 'ruby-openai', '~> 8.1'
gem 'faraday-retry'
```

## Next Steps
- [Configure Environment Variables](environment.md)
- [Understand Memory System](../memory-system/overview.md)
- [Explore API Endpoints](../api/endpoints.md)
