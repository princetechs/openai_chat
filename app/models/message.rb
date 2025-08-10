class Message < ApplicationRecord
  belongs_to :chat
  
  ROLE_USER = 'user'
  ROLE_ASSISTANT = 'assistant'
  ROLE_SYSTEM = 'system'
  
  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: [ROLE_USER, ROLE_ASSISTANT, ROLE_SYSTEM] }
end
