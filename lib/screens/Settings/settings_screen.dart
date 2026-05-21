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
  bool _allowDirectAdd = true;
  bool _desktopNotifications = true;
  bool _weeklySummary = true;
  bool _compactView = false;
  bool _publicActivity = true;
  bool _deadlineEmails = true;


  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _allowDirectAdd = user?.profile?.allowDirectAdd ?? true;
    _publicActivity = user?.profile?.publicActivity ?? true;
  }

  void _showDeactivateConfirmation(bool isAr) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isAr ? 'تعطيل الحساب' : 'Deactivate Account',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isAr
                ? 'هل أنت متأكد من تعطيل حسابك؟ سيتم أرشفة جميع بياناتك وسجل مهامك بشكل آمن.'
                : 'Are you sure you want to deactivate your account? All your data and task histories will be securely archived.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isAr ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'تم تعطيل الحساب بنجاح' : 'Account deactivated successfully'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(isAr ? 'تأكيد التعطيل' : 'Deactivate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAr = languageProvider.isArabic;
    
    // Short inline translation helper
    String tr(String en, String ar) => isAr ? ar : en;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: 'settings'),
          Expanded(
            child: Column(
              children: [
                Header(title: tr('Settings', 'الإعدادات'), showCreateButton: false),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('App Preferences & Workspace Settings', 'إعدادات الحساب والتفضيلات'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF23393E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('Configure your workspace setup, notification digests, bilingual language, and system preferences.',
                               'قم بتهيئة مساحة عملك، وملخصات الإشعارات، ولغة التطبيق، وتفضيلات النظام الأخرى.'),
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF23393E).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 1. Workspace & Collaboration Card
                          _buildCard(
                            title: tr('Workspace & Team Settings', 'بيانات مساحة العمل والتعاون'),
                            subtitle: tr('Configure visibility feeds and automatic adding controls.', 
                                         'إدارة مستويات الظهور، وصلاحيات الإضافة المباشرة للفرق.'),
                            icon: Icons.group_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildToggleRow(
                                  title: tr('Allow Direct Additions', 'السماح بالإضافة المباشرة للمشاريع'),
                                  subtitle: tr('Allow project managers to add you directly to projects via username without approval.', 'السماح لمديري المشاريع بإضافتك مباشرة عبر اسم المستخدم دون طلب موافقة.'),
                                  value: _allowDirectAdd,
                                  onChanged: (val) async {
                                    setState(() => _allowDirectAdd = val);
                                    final success = await ApiService.updateAllowDirectAdd(val);
                                    if (!success) {
                                      setState(() => _allowDirectAdd = !val);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(tr('Failed to update settings', 'فشل تحديث الإعدادات'))),
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
                                _buildToggleRow(
                                  title: tr('Show Achievements to Public', 'عرض إنجازاتي للعامة'),
                                  subtitle: tr('Allow others to view your joined projects, active/completed tasks, and points on your public profile.', 'السماح للآخرين برؤية المشاريع المشترك فيها، والمهام، والنقاط في ملفك الشخصي العام.'),
                                  value: _publicActivity,
                                  onChanged: (val) async {
                                    setState(() => _publicActivity = val);
                                    final success = await ApiService.updatePublicActivity(val);
                                    if (!success) {
                                      setState(() => _publicActivity = !val);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(tr('Failed to update settings', 'فشل تحديث الإعدادات'))),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        Provider.of<AuthProvider>(context, listen: false).updateLocalPublicActivity(val);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Notification Preferences Card
                          _buildCard(
                            title: tr('Notification Channels & Alerts', 'تفضيلات وقنوات الإشعارات'),
                            subtitle: tr('Configure real-time push alerts, email digests, and task deadlines warnings.', 'تهيئة التنبيهات الفورية وملخصات البريد الإلكتروني وتنبيهات المواعيد النهائية.'),
                            icon: Icons.notifications_none,
                            child: Column(
                              children: [
                                _buildToggleRow(
                                  title: tr('Desktop Push Alerts', 'إشعارات سطح المكتب'),
                                  subtitle: tr('Receive real-time sound and banner alerts inside the browser when tasks are assigned.', 'استلام إشعارات فورية صوتية ومرئية داخل المتصفح عند إسناد مهام جديدة إليك.'),
                                  value: _desktopNotifications,
                                  onChanged: (val) => setState(() => _desktopNotifications = val),
                                ),
                                _buildDivider(),
                                _buildToggleRow(
                                  title: tr('Deadline Alerts', 'تنبيهات اقتراب المواعيد النهائية'),
                                  subtitle: tr('Receive warning emails 24 hours before your active tasks reach their deadlines.', 'استلام رسائل بريد تحذيرية قبل 24 ساعة من انتهاء مواعيد مهامك النشطة.'),
                                  value: _deadlineEmails,
                                  onChanged: (val) => setState(() => _deadlineEmails = val),
                                ),
                                _buildDivider(),
                                _buildToggleRow(
                                  title: tr('Weekly Analytics Digest', 'ملخص التحليلات الأسبوعي'),
                                  subtitle: tr('Receive a complete project performance and stats summary every Monday morning.', 'استلام ملخص شامل لأداء المشاريع والإحصائيات كل صباح يوم اثنين.'),
                                  value: _weeklySummary,
                                  onChanged: (val) => setState(() => _weeklySummary = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. App Preferences Card
                          _buildCard(
                            title: tr('App Preferences', 'تفضيلات التطبيق'),
                            subtitle: tr('Configure language layout toggling and interface Density.', 'تهيئة لغة الواجهات ومستوى كثافة العناصر والمسافات.'),
                            icon: Icons.settings_brightness_outlined,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tr('App Language', 'لغة التطبيق'),
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF23393E)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tr('Toggle instantly between English and Arabic layouts.', 'التبديل الفوري بين واجهات اللغة العربية والإنجليزية.'),
                                              style: TextStyle(fontSize: 12, color: const Color(0xFF23393E).withOpacity(0.6)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => languageProvider.toggleLanguage(),
                                        icon: const Icon(Icons.translate, size: 16, color: Colors.white),
                                        label: Text(
                                          isAr ? 'English (EN)' : 'العربية (AR)',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF23393E),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDivider(),
                                _buildToggleRow(
                                  title: tr('Compact Spacing Layout', 'تنسيق المسافات المضغوط'),
                                  subtitle: tr('Compact spacing to display more resource items and cards on a single page.', 'ضغط العناصر والمسافات لعرض المزيد من المهام والمشاريع في الشاشة الواحدة.'),
                                  value: _compactView,
                                  onChanged: (val) => setState(() => _compactView = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 4. Danger Zone Card (Premium Red Container)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('Danger Zone', 'منطقة الخطورة والأمان'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tr('Clear Local System Cache', 'مسح الذاكرة المؤقتة المحلية'),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tr('Wipes local database buffers, forcing fresh sync of active task lists.',
                                               'يمسح ذاكرة التخزين المؤقت المحلية، مما يجبر النظام على إعادة مزامنة كافة المهام والبيانات.'),
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: Text(tr('Clear Cache?', 'مسح الذاكرة المؤقتة؟')),
                                            content: Text(tr('Are you sure you want to clear local storage cache? The app will load fresh data from the server.', 'هل أنت متأكد من مسح الذاكرة المؤقتة؟ سيقوم التطبيق بتحميل بيانات جديدة من الخادم.')),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'إلغاء'))),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(tr('Local cache cleared successfully!', 'تم مسح الذاكرة المؤقتة المحلية بنجاح!')),
                                                      backgroundColor: const Color(0xFF23393E),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF23393E)),
                                                child: Text(tr('Clear', 'مسح')),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade800,
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(tr('Clear Cache', 'مسح المؤقت')),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.red.shade100, thickness: 1),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tr('Deactivate Workspace Account', 'تعطيل الحساب الشخصي'),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tr('Permanently archiving all your collaborative tasks and deliverables safely.',
                                               'سيتم أرشفة كامل بياناتك وتسليماتك السابقة بأمان في النظام دون فقدانها.'),
                                            style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _showDeactivateConfirmation(isAr),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade800,
                                        side: BorderSide(color: Colors.red.shade200),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        tr('Deactivate', 'تعطيل الحساب'),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF23393E), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF23393E).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23393E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF23393E).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF23393E),
            activeTrackColor: const Color(0xFF23393E).withOpacity(0.25),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: const Color(0xFF23393E).withOpacity(0.08), height: 1);
  }
}
