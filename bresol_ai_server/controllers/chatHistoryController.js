const ChatHistoryService = require('../services/chatHistoryService');

const saveChatHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { chatHistory } = req.body;

    const { savedCount } = await ChatHistoryService.saveChatHistory(userId, chatHistory);

    res.json({
      success: true,
      message: 'Chat history saved successfully',
      savedSessions: savedCount
    });
  } catch (error) {
    console.error('Error saving chat history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save chat history',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

const getChatHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit, offset } = req.pagination;

    const result = await ChatHistoryService.getChatHistory(userId, limit, offset);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error retrieving chat history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve chat history',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

const getChatSession = async (req, res) => {
  try {
    const { userId, sessionId } = req.params;

    const chatSession = await ChatHistoryService.getChatSession(userId, sessionId);

    if (!chatSession) {
      return res.status(404).json({
        success: false,
        message: 'Chat session not found'
      });
    }

    res.json({
      success: true,
      data: chatSession
    });
  } catch (error) {
    console.error('Error retrieving chat session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve chat session',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

const deleteChatSession = async (req, res) => {
  try {
    const { userId, sessionId } = req.params;

    const deleted = await ChatHistoryService.deleteChatSession(userId, sessionId);

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: 'Chat session not found'
      });
    }

    res.json({
      success: true,
      message: 'Chat session deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting chat session:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete chat session',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

module.exports = {
  saveChatHistory,
  getChatHistory,
  getChatSession,
  deleteChatSession
};
