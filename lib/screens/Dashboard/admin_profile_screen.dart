import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/models/user_model.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

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
    final langProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFC7CDCA),
      body: Column(
        children: [
          const AdminTopNav(activeItem: 'Profile'),
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
                            _buildProfileHeaderCard(langProvider),
                            const SizedBox(height: 24),
                            _buildAccountSettingsCard(langProvider),
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

  Widget _buildProfileHeaderCard(LanguageProvider langProvider) {
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
            child: Text(
              langProvider.translate('edit_profile'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard(LanguageProvider langProvider) {
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
                Text(
                  langProvider.translate('account_overview'),
                  style: const TextStyle(
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
                Text(
                  langProvider.translate('account_settings'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33423E),
                  ),
                ),
                Text(
                  langProvider.translate('manage_admin_profile'),
                  style: const TextStyle(
                    color: Color(0xFF7A8B86),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSettingItem(
                  Icons.email_outlined,
                  langProvider.translate('email_address'),
                  _user?.email ?? 'admin@example.com',
                ),
                const Divider(height: 32, color: Color(0xFFECECEC)),
                _buildSettingItem(
                  Icons.phone_outlined,
                  langProvider.translate('phone_number'),
                  '+967 736 047 368',
                ),
                const Divider(height: 32, color: Color(0xFFECECEC)),
                _buildSettingItem(
                  Icons.history,
                  langProvider.translate('last_login'),
                  'October 24, 2023 - 14:20 PM',
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: Text(langProvider.translate('change_password')),
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
                        label: Text(langProvider.translate('export_data')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color(0xFF7A8B86),
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
