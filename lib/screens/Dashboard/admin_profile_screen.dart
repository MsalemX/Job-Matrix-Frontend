import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/models/user_model.dart';
import 'package:job_matrix_forntend/screens/Auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final user = await ApiService.getMyProfile();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7CDCA),
      body: Column(
        children: [
          _buildTopNav(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            _buildProfileHeaderCard(),
                            const SizedBox(height: 24),
                            _buildAccountSettingsCard(),
                            const SizedBox(height: 24),
                            const Text(
                              '• JOB MATRIX V1.0 •',
                              style: TextStyle(
                                color: Color(0xFF7A8B86),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: const Color(0xFF33423E),
      child: Row(
        children: [
          const Icon(Icons.grid_view_sharp, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Job Matrix',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          _buildNavItem('Dashboard', onTap: () => Navigator.pop(context)),
          _buildNavItem('Users'),
          _buildNavItem('Projects'),
          _buildNavItem('Reports'),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF423333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(width: 24),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF7A8B86),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFC7CDCA),
            backgroundImage: _user?.profile?.profileImage != null
                ? NetworkImage(_user!.profile!.profileImage!)
                : null,
            child: _user?.profile?.profileImage == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 24),
          Text(
            _user?.name ?? 'Super Admin',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF33423E),
            ),
          ),
          Text(
            '@${_user?.username ?? 'admin'}',
            style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF33423E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF33423E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33423E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 100,
                  color: const Color(0xFF33423E),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33423E),
                  ),
                ),
                const Text(
                  'Manage your administrative profile and preferences.',
                  style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
                ),
                const SizedBox(height: 32),
                _buildSettingItem(
                  Icons.email_outlined,
                  'Email Address',
                  _user?.email ?? 'admin@example.com',
                ),
                const Divider(height: 32, color: Color(0xFFECECEC)),
                _buildSettingItem(
                  Icons.phone_outlined,
                  'Phone Number',
                  '+967 736 047 368', // Hardcoded as per design or fetch from profile if exists
                ),
                const Divider(height: 32, color: Color(0xFFECECEC)),
                _buildSettingItem(
                  Icons.history,
                  'Last Login',
                  'October 24, 2023 - 14:20 PM',
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: const Text('Change Password'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color(0xFF33423E),
                          side: const BorderSide(color: Color(0xFF33423E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export Data'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Color(0xFF7A8B86),
                          side: const BorderSide(color: Color(0xFFECECEC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A8B86), size: 20),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF33423E),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
