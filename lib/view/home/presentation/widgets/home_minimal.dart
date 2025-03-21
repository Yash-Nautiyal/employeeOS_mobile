import 'package:flutter/material.dart';

class MinimalFeatures extends StatelessWidget {
  const MinimalFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purple.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Top divider
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 24),

              // Header text
              const Text(
                'VISUALIZING SUCCESS',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Title with gradient
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "What's in ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2B3C),
                      ),
                    ),
                    TextSpan(
                      text: "Minimal?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Feature items
              const FeatureItem(
                icon: Icons.extension_outlined,
                title: 'Branding',
                description:
                    'Consistent design makes it easy to brand your own.',
              ),
              const SizedBox(height: 24),

              const FeatureItem(
                icon: Icons.grid_3x3_outlined,
                title: 'UI & UX Design',
                description:
                    'The kit is built on the principles of the atomic design system.',
              ),
              const SizedBox(height: 24),

              const FeatureItem(
                icon: Icons.code_outlined,
                title: 'Development',
                description:
                    'Easy to customize and extend, saving you time and money.',
              ),
              const SizedBox(height: 32),

              // Bottom divider
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2B3C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Usage:
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: MinimalFeatures(),
//   ));
// }
