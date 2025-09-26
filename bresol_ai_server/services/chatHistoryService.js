const ChatSession = require('../models/ChatSession');
const ChatMessage = require('../models/ChatMessage');

class ChatHistoryService {
  
  // 📤 Save chat history
  static async saveChatHistory(userId, chatHistory) {
    let savedCount = 0;

    for (const session of chatHistory) {
      const { id, title, createdAt, messages } = session;

      if (!id || !title || !messages || !Array.isArray(messages)) {
        continue;
      }

      await ChatSession.createSession({
        id,
        userId: parseInt(userId),
        title,
        createdAt
      });

      await ChatMessage.createMessages(id, messages);
      savedCount++;
    }

    return { savedCount };
  }

  // 📥 Get all chat sessions with pagination
  static async getChatHistory(userId, limit, offset) {
    const sessions = await ChatSession.getSessionsByUserId(
      parseInt(userId),
      limit,
      offset
    );

    const chatHistory = [];
    for (const session of sessions) {
      const messages = await ChatMessage.getMessagesBySessionId(session.id);

      chatHistory.push({
        id: session.id,
        title: session.title,
        createdAt: session.created_at,
        updatedAt: session.updated_at,
        messages
      });
    }

    const total = await ChatSession.getSessionCount(parseInt(userId));

    return {
      chatHistory,
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + limit < total
      }
    };
  }

  // 📄 Get single chat session by ID
  static async getChatSession(userId, sessionId) {
    const session = await ChatSession.getSessionById(sessionId, parseInt(userId));
    if (!session) return null;

    const messages = await ChatMessage.getMessagesBySessionId(sessionId);

    return {
      id: session.id,
      title: session.title,
      createdAt: session.created_at,
      updatedAt: session.updated_at,
      messages
    };
  }

  // 🗑️ Delete chat session
  static async deleteChatSession(userId, sessionId) {
    return await ChatSession.deleteSession(sessionId, parseInt(userId));
  }
}

module.exports = ChatHistoryService;
