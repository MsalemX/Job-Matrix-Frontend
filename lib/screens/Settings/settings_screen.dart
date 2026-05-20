import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _desktopNotifications = true;
  bool _weeklySummary = true;
  bool _compactView = false;
  bool _publicActivity = true;
  bool _allowDirectAdd = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _allowDirectAdd = authProvider.user?.profile?.allowDirectAdd ?? true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const Sidebar(currentRoute: 'settings'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Settings', showCreateButton: false),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGeneralPreferences(),
                        const SizedBox(height: 32),
                        _buildDeactivateAccount(),
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

  Widget _buildGeneralPreferences() {
    final isAr = Provider.of<LanguageProvider>(context).isArabic;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(
          0xFFC0C7C4,
        ).withAlpha(100), // Matching the grayish card background
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
      child: Column(
        children: [
          Text(
            isAr ? 'الإعدادات العامة' : 'General Preferences',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF23393E),
            ),
          ),
          const SizedBox(height: 48),
          _buildToggleItem(
            isAr ? 'السماح بالإضافة المباشرة' : 'Allow Direct Additions',
            isAr
                ? 'إذا تم تفعيل هذا الخيار، سيتمكن مديرو المشاريع من إضافتك مباشرة عن طريق اسم المستخدم.'
                : 'Allow project managers to add you directly via username.',
            _allowDirectAdd,
            (val) async {
              setState(() => _allowDirectAdd = val);
              final success = await ApiService.updateAllowDirectAdd(val);
              if (!success) {
                // Revert on failure
                setState(() => _allowDirectAdd = !val);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? 'فشل تحديث الإعدادات'
                            : 'Failed to update settings',
                      ),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  Provider.of<AuthProvider>(context, listen: false).updateLocalAllowDirectAdd(val);
                }
              }
            },
          ),
          _buildDivider(),
          _buildToggleItem(
            isAr ? 'إشعارات سطح المكتب' : 'Desktop Notifications',
            isAr
                ? 'استلام تنبيهات فورية على سطح المكتب.'
                : 'Receive real-time alerts on your desktop.',
            _desktopNotifications,
            (val) => setState(() => _desktopNotifications = val),
          ),
          _buildDivider(),
          _buildToggleItem(
            isAr ? 'ملخص أسبوعي بالبريد' : 'Weekly Summary Email',
            isAr
                ? 'ملخص أسبوعي حول تقدم مشروعك كل اثنين.'
                : 'A digest of your project progress every Monday.',
            _weeklySummary,
            (val) => setState(() => _weeklySummary = val),
          ),
          _buildDivider(),
          _buildToggleItem(
            isAr ? 'عرض مضغوط' : 'Compact View',
            isAr
                ? 'إظهار المزيد من العناصر في لوحة القيادة.'
                : 'Show more items per page in dashboard lists.',
            _compactView,
            (val) => setState(() => _compactView = val),
          ),
          _buildDivider(),
          _buildToggleItem(
            isAr ? 'النشاط العام' : 'Public Activity Feed',
            isAr
                ? 'السماح لأعضاء الفريق برؤية سجل مهامك.'
                : 'Allow team members to see your task history.',
            _publicActivity,
            (val) => setState(() => _publicActivity = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF23393E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF23393E).withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF23393E),
            activeTrackColor: const Color(0xFF23393E).withAlpha(100),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: const Color(0xFF23393E).withAlpha(30), height: 1);
  }

  Widget _buildDeactivateAccount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE).withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade100,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deactivate Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Once you deactivate your account, all your data will be archived.',
                  style: TextStyle(fontSize: 14, color: Colors.red.shade600),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Deactivate logic
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade800,
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Deactivate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
