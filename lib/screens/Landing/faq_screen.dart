import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/screens/Landing/contact_us_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Is Job Matrix free to use?',
      'answer':
          'We offer a free tier with basic features. For advanced project management and team collaboration, we have premium plans.',
      'id': 1,
    },
    {
      'question': 'How do I add team members?',
      'answer':
          'Go to your project settings, find the "Team" tab, and click "Invite Member". You can invite them via email.',
      'id': 2,
    },
    {
      'question': 'Can I export my data?',
      'answer':
          'Yes, you can export your project data in CSV, PDF, and JSON formats from the reporting dashboard.',
      'id': 3,
    },
    {
      'question': 'What platforms are supported?',
      'answer':
          'Job Matrix is available on Web, iOS, Android, and Desktop (Windows & Mac).',
      'id': 4,
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'We use industry-standard encryption (AES-256) and secure cloud providers to ensure your data is always safe and private.',
      'id': 5,
    },
  ];

  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: Color(0xFF2D464C),
            fontWeight: FontWeight.bold,
          ),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: _faqs.map((faq) => _buildFAQItem(faq)).toList(),
              ),
            ),
            const SizedBox(height: 60),
            _buildCTA(),
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
            'FAQs',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Find answers to common questions and learn more about Job Matrix.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    bool isExpanded = _expandedId == faq['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF2D464C).withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          title: Text(
            faq['question'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpanded ? const Color(0xFF2D464C) : Colors.black87,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: isExpanded ? const Color(0xFF2D464C) : Colors.grey,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                faq['answer'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ),
          ],
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedId = expanded ? faq['id'] : null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCTA() {
    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D464C),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'If you cannot find the answer you are looking for, please contact our support team.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactUsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D464C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Contact Support',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
