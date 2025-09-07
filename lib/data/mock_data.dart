import 'package:intl/intl.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MockData {
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM d');
  
  static List<Conversation> getMockConversations() {
    final now = DateTime.now();
    final earlierToday = now.subtract(const Duration(hours: 3));
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final conversations = <Conversation>[];

    // Conversation 1
    final convo1 = Conversation(
      id: '1',
      contactName: 'John Doe',
      lastMessage: 'Hey, how are you doing?',
      timestamp: earlierToday,
      unreadCount: 2,
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    );
    
    conversations.add(convo1.addMessage(
      Message(
        id: '1',
        text: 'Hey there!',
        isSentByMe: false,
        timestamp: earlierToday.subtract(const Duration(minutes: 10)),
      ),
    ).addMessage(
      Message(
        id: '2',
        text: 'How are you doing?',
        isSentByMe: false,
        timestamp: earlierToday,
      ),
    ));

    // Conversation 2
    final convo2 = Conversation(
      id: '2',
      contactName: 'Jane Smith',
      lastMessage: 'The meeting is at 2 PM',
      timestamp: yesterday,
      unreadCount: 0,
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    );
    
    conversations.add(convo2.addMessage(
      Message(
        id: '3',
        text: 'Hi Jane, when is our next meeting?',
        isSentByMe: true,
        timestamp: yesterday.subtract(const Duration(hours: 1)),
      ),
    ).addMessage(
      Message(
        id: '4',
        text: 'The meeting is at 2 PM',
        isSentByMe: false,
        timestamp: yesterday,
      ),
    ));

    // Conversation 3
    final convo3 = Conversation(
      id: '3',
      contactName: 'Team Flutter',
      lastMessage: 'Alice: I finished the UI changes',
      timestamp: twoDaysAgo,
      unreadCount: 5,
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    );
    
    final updatedMessages = [
      Message(
        id: '5',
        text: 'Bob: Has everyone finished their tasks?',
        isSentByMe: false,
        timestamp: twoDaysAgo.subtract(const Duration(hours: 2)),
        senderId: 'bob',
      ),
      Message(
        id: '6',
        text: 'I\'m still working on the backend',
        isSentByMe: true,
        timestamp: twoDaysAgo.subtract(const Duration(hours: 1)),
      ),
      Message(
        id: '7',
        text: 'I finished the UI changes',
        isSentByMe: false,
        timestamp: twoDaysAgo,
        senderId: 'alice',
      ),
    ];
    
    final updatedConvo3 = convo3.copyWith(
      messages: [...convo3.messages, ...updatedMessages],
      lastMessage: 'Alice: I finished the UI changes',
    );
    conversations.add(updatedConvo3);

    return conversations;
  }

  // Format time for message timestamps
  static String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      return _timeFormat.format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older than a week - show date
      return _dateFormat.format(timestamp);
    }
  }
}
