import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back, MsalemX',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'You have 12 active projects and 4 tasks.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 48),

                        _buildSectionHeader('My Projects'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              DashboardCard(
                                title: 'Marketing Website Revamp',
                                subtitle:
                                    'Complete redesign of the corporate marketing assets for Q4 product launches.',
                                status: 'In Progress',
                                progress: 0.75,
                                icon: Icons.rocket_launch,
                                timeLeft: '3 days left',
                              ),
                              SizedBox(width: 20),
                              DashboardCard(
                                title: 'Mobile App V2.0',
                                subtitle:
                                    'Prototyping and wireframing for the next major release of the mobile application.',
                                status: 'Planning',
                                progress: 0.12,
                                icon: Icons.phone_android,
                                timeLeft: '1 week left',
                              ),
                              SizedBox(width: 20),
                              DashboardCard(
                                title: 'Quarterly Report Q3',
                                subtitle:
                                    'Final performance review and statistical data aggregation for the third quarter.',
                                status: 'Completed',
                                progress: 1.0,
                                icon: Icons.assignment,
                                timeLeft: 'Closed',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),
                        _buildSectionHeader('Joined Projects'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const DashboardCard(
                                title: 'UX Research Phase',
                                subtitle:
                                    'User testing and interview sessions for the new onboarding flow.',
                                status: 'In Progress',
                                progress: 0.45,
                                icon: Icons.edit,
                                timeLeft: '12',
                              ),
                              const SizedBox(width: 20),
                              const DashboardCard(
                                title: 'API Integration',
                                subtitle:
                                    'Connecting third-party logistics data streams to the main dashboard.',
                                status: 'In Progress',
                                progress: 0.88,
                                icon: Icons.api,
                                timeLeft: 'Due Today',
                              ),
                              const SizedBox(width: 20),
                              _buildCreateNewCard(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),
                        _buildSectionHeader('My Tasks'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              DashboardCard(
                                title:
                                    'Migrating Servers to a Cloud Environment',
                                subtitle:
                                    'Analyzing requirements and choosing the most suitable cloud service provider.',
                                status: 'In Progress',
                                progress: 0.75,
                                icon: Icons.rocket_launch,
                              ),
                              SizedBox(width: 20),
                              DashboardCard(
                                title: 'API Development',
                                subtitle:
                                    'Building and documenting API endpoints for user and product services.',
                                status: 'Planning',
                                progress: 0.12,
                                icon: Icons.code,
                              ),
                              SizedBox(width: 20),
                              DashboardCard(
                                title: 'Launch of the Q1 Advertising Campaign',
                                subtitle:
                                    'The marketing campaign has been launched across digital platforms.',
                                status: 'Completed',
                                progress: 1.0,
                                icon: Icons.campaign,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.stars, color: Colors.black87, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'View All',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateNewCard() {
    return Container(
      width: 300,
      height: 260, // approximate height of DashboardCard
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.black54, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start New Project',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            'Need help? Invite your team',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
