enum AssistantMessageRole { user, assistant }

class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final AssistantMessageRole role;
  final String text;
  final DateTime timestamp;
}
