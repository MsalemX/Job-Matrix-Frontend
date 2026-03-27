import 'package:flutter/material.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tutorials',
          style: TextStyle(color: Color(0xFF2D464C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D464C)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Featured Tutorials',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
                  ),
                  const SizedBox(height: 32),
                  _buildTutorialGrid(context),
                  const SizedBox(height: 60),
                  const Text(
                    'Browse Categories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
                  ),
                  const SizedBox(height: 32),
                  _buildCategoryList(),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: const Color(0xFF2D464C),
      child: Column(
        children: const [
          Text(
            'Master Job Matrix',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Learn how to streamline your workflow with our step-by-step guides.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialGrid(BuildContext context) {
    final tutorials = [
      {'title': 'Platform Overview', 'duration': '5 mins', 'type': 'Video'},
      {'title': 'Advanced Task Management', 'duration': '10 mins', 'type': 'Article'},
      {'title': 'Team Collaboration Tips', 'duration': '8 mins', 'type': 'Video'},
      {'title': 'Understanding Analytics', 'duration': '12 mins', 'type': 'Video'},
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: tutorials.map((t) => _buildTutorialCard(context, t)).toList(),
    );
  }

  Widget _buildTutorialCard(BuildContext context, Map<String, dynamic> tutorial) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF2D464C).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_outline, color: Color(0xFF2D464C), size: 64),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D464C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tutorial['type'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tutorial['duration'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tutorial['title'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ['Getting Started', 'Project Setup', 'Team Management', 'Reporting', 'Billing'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ActionChip(
      onPressed: () {},
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
