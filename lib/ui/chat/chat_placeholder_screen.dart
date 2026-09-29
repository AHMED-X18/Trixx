import 'package:flutter/material.dart';
import 'package:trixx/ui/theme/app_colors.dart';

/// Stand-in for the Chat tab until the intent router and Gemini
/// integration (P2 of the roadmap) are implemented.
class ChatPlaceholderScreen extends StatelessWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
              SizedBox(height: 12),
              Text(
                'Chat IA — bientôt disponible',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Le routeur d\'intention et l\'assistant conversationnel arrivent dans une prochaine étape.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
