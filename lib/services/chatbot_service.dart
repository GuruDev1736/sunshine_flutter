import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUserMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "message": message,
      "isUserMessage": isUserMessage,
      "timestamp": Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map["id"] ?? "",
      userId: map["userId"] ?? "",
      message: map["message"] ?? "",
      isUserMessage: map["isUserMessage"] ?? true,
      timestamp: (map["timestamp"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatbotService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _geminiService = GeminiService();

  String get _userId => _auth.currentUser?.uid ?? "";

  /// Get chat history
  Stream<QuerySnapshot> getChatHistory() {
    return _db
        .collection("chatbot_messages")
        .where("userId", isEqualTo: _userId)
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Save chat message to Firestore
  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      await _db
          .collection("chatbot_messages")
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      throw "Error saving chat message: $e";
    }
  }

  /// Send message and get AI response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Get AI response
      final aiResponse = await _geminiService.generateChatbotResponse(
        userMessage,
      );
      return aiResponse;
    } catch (e) {
      return "I'm unable to process your question right now. Please try again.";
    }
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    try {
      final messages = await _db
          .collection("chatbot_messages")
          .where("userId", isEqualTo: _userId)
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw "Error clearing chat history: $e";
    }
  }

  /// Get frequently asked questions
  static const List<Map<String, String>> faqList = [
    {
      "question": "What documents are required for travel?",
      "answer":
          "You'll need a valid passport, visa (if applicable), travel insurance, and any required vaccinations.",
    },
    {
      "question": "How can I find budget-friendly hotels?",
      "answer":
          "Use our app's search filters to find hotels within your budget. We also suggest homestays and guesthouses.",
    },
    {
      "question": "What's the best time to travel to India?",
      "answer":
          "The best time is October to March when weather is pleasant. Avoid monsoon season (June-September).",
    },
    {
      "question": "How do I get help during emergencies?",
      "answer":
          "Contact your nearest embassy or consulate. Also maintains emergency contacts list in the app.",
    },
    {
      "question": "Can I modify a travel plan after creating it?",
      "answer":
          "Yes, you can edit your travel plans anytime. Changes are saved to your account.",
    },
    {
      "question": "How do I share my travel plan?",
      "answer":
          "You can save plans for others to view and review. They can also create their own version.",
    },
    {
      "question": "Are there discounts for group travel?",
      "answer":
          "Many hotels and attractions offer group discounts. Arrange through your accommodation provider.",
    },
    {
      "question": "What's the safest mode of transportation?",
      "answer":
          "Trains and flights are generally safest. Use authorized taxi services and avoid traveling alone at night.",
    },
  ];

  /// Get FAQ by index
  static Map<String, String>? getFAQByIndex(int index) {
    if (index >= 0 && index < faqList.length) {
      return faqList[index];
    }
    return null;
  }
}
