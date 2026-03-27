import 'package:flutter/material.dart';
import '../Auth/auth_selection_screen.dart';
import 'contact_us_screen.dart';
import 'help_center_screen.dart';
import 'faq_screen.dart';
import 'tutorials_screen.dart';
import 'terms_of_service_screen.dart';
import 'conditions_screen.dart';
import 'cookie_policy_screen.dart';
import 'privacy_policy_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _problemKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _whyUsKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _AnimatedSection(key: _homeKey, child: _buildHeroSection(context)),
            _buildProblemSolveSection(context, key: _problemKey),
            _buildFeaturesSection(context, key: _featuresKey),
            _buildTeamSection(context, key: _teamKey),
            _buildWhyUsSection(context, key: _whyUsKey),
            _buildCTASection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Column(
        children: [
          const Text(
            'Job Matrix',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Illustration Hero
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              'assets/images/landing 1.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Stramline Your Workflow',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D464C),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Deliver on tile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D464C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthSelectionScreen(),
                ),
              );
            },
            icon: const Text('Get Started'),
            label: const Icon(Icons.arrow_forward),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF90A4AE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemSolveSection(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.all(32.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          return Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 40,
            runSpacing: 40,
            children: [
              SizedBox(
                width: isWide ? 400 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Problem & Solve',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D464C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Managing projects often becomes complex, with tasks getting lost, progress hard to track, and time and cost estimates falling short, which leads to delays and budget overruns. Our system solves this by breaking projects into clear Work Breakdown Structures (WBS), intelligently tracking time and cost, and leveraging AI-powered analytics to predict risks, evaluate performance, and keep projects under control from start to finish.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Image/Icon Placeholder
              Container(
                width: isWide ? 400 : double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/problem.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D464C),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 900;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 60,
                runSpacing: 40,
                children: [
                  // WBS Diagram Placeholder
                  Container(
                    width: isWide ? 450 : double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/Features.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 400 : double.infinity,
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          '1',
                          'Smart Work Breakdown Structure (WBS)',
                          'Break projects into clear, manageable tasks for better planning and control',
                        ),
                        _buildFeatureItem(
                          '2',
                          'Team Management',
                          'Assign tasks, track progress, and keep teams aligned in one platform',
                        ),
                        _buildFeatureItem(
                          '3',
                          'Simple Dashboard',
                          'Get a clear overview of project status through an intuitive, easy-to-use dashboard',
                        ),
                        _buildFeatureItem(
                          '4',
                          'Task & Resource Tracker',
                          'Monitor tasks, workloads, and resource allocation in real-time',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D464C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D464C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      color: const Color(0xFF90A4AE), // Solid color from screenshot
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'Our Team',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTeamMember(
                  'Mohammed Salem Alhanshi',
                  'Flutter Developer',
                  'A Flutter developer is a software developer who builds cross-platform mobile applications using the Flutter framework.',
                  'assets/images/team/Mohammed Salem Alhanshi.jpg',
                ),
                _buildTeamMember(
                  "Assem Ahmed Ba'abbad",
                  'Developer',
                  'A software developer is a professional who creates, tests, and maintains computer programs and applications.',
                  'assets/images/team/Assem_Ahmed_Baabbad.jpg',
                ),
                _buildTeamMember(
                  "Mohammed Waheb Ba'issa",
                  'Developer',
                  'A software developer is a professional who creates, tests, and maintains computer programs and applications.',
                  "assets/images/team/Mohammed Waheb Ba'issa.jpg",
                ),
                _buildTeamMember(
                  'Fawaz Akram Basoura',
                  'Developer',
                  'A software developer is a professional who creates, tests, and maintains computer programs and applications.',
                  'assets/images/team/Fawaz Akram Basoura.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    String name,
    String role,
    String description,
    String imageName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: 200, // Slightly wider to accommodate names
        child: Column(
          children: [
            Container(
              height: 220, // Slightly taller
              width: 180, // Consistent width
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageName,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white54,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              role,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80, // Fixed height for description uniformity
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyUsSection(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      color: const Color(0xFF2D464C), // Dark section
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'Why Us?',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Built on Real-World Project Management Methodologies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _buildWhyItem(
            'Designed from practical experience, not\njust theory, to ensure projects succeed',
          ),
          _buildWhyItem('Actionable AI, Not Just a Buzzword', isTitle: true),
          _buildWhyItem(
            'AI features deliver real insights that\nimprove performance and prevent risks',
          ),
          _buildWhyItem('Flexible & Fully Customizable', isTitle: true),
          _buildWhyItem(
            'Adapts to any team, workflow, or project\nsize with their unique needs',
          ),
          _buildWhyItem('Effortless to Learn & Use', isTitle: true),
          _buildWhyItem(
            'Get your team productive instantly with an\nintuitive, user-friendly interface',
          ),
        ],
      ),
    );
  }

  Widget _buildWhyItem(String text, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTitle ? 22 : 16,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          color: isTitle ? Colors.white : Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFC3C6C3), // Light grey background
      ),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'Ready To Boost Your Team Productivity?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Join thousands of teams who are delivering\nprojects faster with Job Matrix',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xff4B5563),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D464C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
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
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D464C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Contact us',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: const Color(0xFF001A1A), // Very dark footer
      padding: const EdgeInsets.all(48.0),
      width: double.infinity,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              return Wrap(
                alignment: WrapAlignment.start,
                spacing: 60,
                runSpacing: 40,
                children: [
                  SizedBox(
                    width: isWide ? 250 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Job Matrix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Making project management effortless of all sezis.\nPlan, Track and deliver with confidence.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFooterColumn('Quick Links', [
                    {'title': 'Home', 'onTap': () => _scrollToSection(_homeKey)},
                    {'title': 'Problem', 'onTap': () => _scrollToSection(_problemKey)},
                    {'title': 'Features', 'onTap': () => _scrollToSection(_featuresKey)},
                    {'title': 'Team', 'onTap': () => _scrollToSection(_teamKey)},
                    {'title': 'Why us?', 'onTap': () => _scrollToSection(_whyUsKey)},
                  ]),
                  _buildFooterColumn('Resources / Support', [
                    {
                      'title': 'Help Center',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                        );
                      }
                    },
                    {
                      'title': 'FAQ',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FAQScreen()),
                        );
                      }
                    },
                    {
                      'title': 'Tutorials',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TutorialsScreen()),
                        );
                      }
                    },
                  ]),
                  _buildFooterColumn('Terms', [
                    {
                      'title': 'Terms',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                        );
                      }
                    },
                    {
                      'title': 'Conditions',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConditionsScreen()),
                        );
                      }
                    },
                    {
                      'title': 'Cookie Policy',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CookiePolicyScreen()),
                        );
                      }
                    },
                    {
                      'title': 'Privacy Policy',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                        );
                      }
                    },
                  ]),
                ],
              );
            },
          ),
          const SizedBox(height: 60),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          const Text(
            'Legal / Copyright',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Text(
            '© 2026 Job Matrix. All Rights Reserved',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<Map<String, dynamic>> links) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: link['onTap'],
                child: Text(
                  link['title'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  const _AnimatedSection({super.key, required this.child});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
