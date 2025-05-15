import 'package:bloc/bloc.dart';

// Define ChatbotEvent
abstract class ChatbotEvent {
  const ChatbotEvent();
}

// Add specific events here later, e.g., SendMessageEvent, LoadHistoryEvent

// Define ChatbotState
abstract class ChatbotState {
  const ChatbotState();
}

class ChatbotInitial extends ChatbotState {
  const ChatbotInitial();
}

// Add specific states here later, e.g., ChatbotLoading, ChatbotLoaded, ChatbotError, ChatbotMessageReceived

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  ChatbotBloc() : super(const ChatbotInitial()) {
    // Register event handlers here later
    // on<SendMessageEvent>((event, emit) async { ... });
  }
}
