import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LanguageProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  void toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
    notifyListeners();
  }

  String translate(String key) {
    if (isArabic) {
      return _arabic[key] ?? key;
    }
    return _english[key] ?? key;
  }

  static const Map<String, String> _english = {
    'dashboard': 'Dashboard',
    'users': 'Users',
    'projects': 'Projects',
    'reports': 'Reports',
    'logout': 'Logout',
    'manage_projects': 'Manage Projects',
    'view_manage_projects': 'View and manage all system projects.',
    'project_details_admin': 'Project Details (Admin)',
    'owner': 'Owner',
    'status': 'Status',
    'created_at': 'Created At',
    'participants': 'Participants',
    'tasks': 'Tasks',
    'description': 'Description',
    'delete_project_system': 'Delete Project from System',
    'sections_and_tasks': 'Sections and Tasks',
    'no_sections_found': 'No sections or tasks found for this project yet.',
    'report_details': 'Report Details',
    'system_reports': 'System Reports',
    'view_manage_reports': 'View and manage user-submitted reports for projects and accounts.',
    'reported_target': 'Reported Target',
    'reporter': 'Reporter',
    'project_manager': 'Project Manager',
    'reason': 'Reason',
    'dismiss_report': 'Dismiss Report',
    'take_action_delete': 'Take Action (Delete)',
    'approve_report': 'Approve Report',
    'reject_report': 'Reject Report',
    'cancel': 'Cancel',
    'confirm_delete': 'Confirm Delete',
    'project_deleted_success': 'Project deleted successfully',
    'delete_confirm_msg': 'Are you sure you want to delete this project permanently? This action cannot be undone.',
    'report_about': 'Report about',
    'no_reports_available': 'No reports currently available.',
    'search_resources': 'Search resources...',
    'system_overview': 'System Overview',
    'real_time_metrics': 'Real-time performance metrics and recent administrative activity.',
    'total_projects': 'TOTAL PROJECTS',
    'total_users': 'TOTAL USERS',
    'recent_projects': 'Recent Projects',
    'view_all': 'View All',
    'new_users': 'New Users',
    'server_status': 'Server Status',
    'online': 'Online',
    'edit_profile': 'Edit Profile',
    'account_overview': 'Account Overview',
    'account_settings': 'Account Settings',
    'manage_admin_profile': 'Manage your administrative profile and preferences.',
    'email_address': 'Email Address',
    'phone_number': 'Phone Number',
    'last_login': 'Last Login',
    'change_password': 'Change Password',
    'export_data': 'Export Data',
    'members': 'members',
    'tasks_count': 'tasks',
    'no_tasks': 'No tasks in this section.',
    'no_description': 'No description available.',
    'manage_users': 'Manage Users',
    'view_manage_users': 'View and manage all system users.',
    'id': 'ID',
    'name': 'Name',
    'email': 'Email',
    'role': 'Role',
    'actions': 'Actions',
    'confirm_approve_report': 'Are you sure you want to approve this report? The reported content will be deleted.',
    'confirm_dismiss_report': 'Are you sure you want to dismiss this report?',
    'add_note_optional': 'Add a note for the user (optional)...',
    'confirm_and_delete': 'Confirm and Delete',
    'dismiss': 'Dismiss',
    'report_date': 'Report Date',
    'error_loading_projects': 'Error loading projects',
    'failed_to_delete_project': 'Failed to delete project',
    'error_loading_users': 'Error loading users',
    'failed_to_delete_user': 'Failed to delete user',
    'error_loading_reports': 'Error loading reports',
  };

  static const Map<String, String> _arabic = {
    'dashboard': 'لوحة التحكم',
    'users': 'المستخدمين',
    'projects': 'المشاريع',
    'reports': 'البلاغات',
    'logout': 'تسجيل الخروج',
    'manage_projects': 'إدارة المشاريع',
    'view_manage_projects': 'استعرض وقم بإدارة كافة مشاريع النظام.',
    'project_details_admin': 'تفاصيل المشروع (أدمن)',
    'owner': 'المالك',
    'status': 'الحالة',
    'created_at': 'تاريخ الإنشاء',
    'participants': 'المشاركين',
    'tasks': 'المهام',
    'description': 'الوصف',
    'delete_project_system': 'حذف المشروع من النظام',
    'sections_and_tasks': 'الأقسام والمهام',
    'no_sections_found': 'لا توجد أقسام أو مهام في هذا المشروع حتى الآن.',
    'report_details': 'تفاصيل البلاغ',
    'system_reports': 'بلاغات النظام',
    'view_manage_reports': 'مراجعة البلاغات المقدمة من المستخدمين واتخاذ الإجراءات اللازمة.',
    'reported_target': 'الهدف المبلّغ عنه',
    'reporter': 'مقدم البلاغ',
    'project_manager': 'مدير المشروع',
    'reason': 'السبب',
    'dismiss_report': 'تجاهل البلاغ',
    'take_action_delete': 'اتخاذ إجراء (حذف)',
    'approve_report': 'قبول البلاغ',
    'reject_report': 'رفض البلاغ',
    'cancel': 'إلغاء',
    'confirm_delete': 'تأكيد الحذف',
    'project_deleted_success': 'تم حذف المشروع بنجاح',
    'delete_confirm_msg': 'هل أنت متأكد من رغبتك في حذف هذا المشروع نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
    'report_about': 'بلاغ عن',
    'no_reports_available': 'لا توجد بلاغات حالياً.',
    'search_resources': 'البحث عن موارد...',
    'system_overview': 'نظرة عامة على النظام',
    'real_time_metrics': 'مقاييس الأداء في الوقت الفعلي والنشاط الإداري الأخير.',
    'total_projects': 'إجمالي المشاريع',
    'total_users': 'إجمالي المستخدمين',
    'recent_projects': 'المشاريع الأخيرة',
    'view_all': 'عرض الكل',
    'new_users': 'المستخدمين الجدد',
    'server_status': 'حالة السيرفر',
    'online': 'متصل',
    'edit_profile': 'تعديل الملف الشخصي',
    'account_overview': 'نظرة عامة على الحساب',
    'account_settings': 'إعدادات الحساب',
    'manage_admin_profile': 'إدارة ملفك الشخصي الإداري وتفضيلاتك.',
    'email_address': 'عنوان البريد الإلكتروني',
    'phone_number': 'رقم الهاتف',
    'last_login': 'آخر تسجيل دخول',
    'change_password': 'تغيير كلمة المرور',
    'export_data': 'تصدير البيانات',
    'members': 'أعضاء',
    'tasks_count': 'مهام',
    'no_tasks': 'لا توجد مهام في هذا القسم.',
    'no_description': 'لا يوجد وصف متاح.',
    'manage_users': 'إدارة المستخدمين',
    'view_manage_users': 'استعرض وقم بإدارة كافة مستخدمي النظام.',
    'id': 'المعرف',
    'name': 'الاسم',
    'email': 'البريد الإلكتروني',
    'role': 'الدور',
    'actions': 'الإجراءات',
    'confirm_approve_report': 'هل أنت متأكد من قبول البلاغ؟ سيتم حذف المحتوى المبلغ عنه.',
    'confirm_dismiss_report': 'هل أنت متأكد من تجاهل هذا البلاغ؟',
    'add_note_optional': 'أضف ملاحظة للمستخدم (اختياري)...',
    'confirm_and_delete': 'تأكيد وحذف',
    'dismiss': 'تجاهل',
    'report_date': 'تاريخ البلاغ',
    'error_loading_projects': 'خطأ في تحميل المشاريع',
    'failed_to_delete_project': 'فشل حذف المشروع',
    'error_loading_users': 'خطأ في تحميل المستخدمين',
    'failed_to_delete_user': 'فشل حذف المستخدم',
    'error_loading_reports': 'خطأ في تحميل البلاغات',
  };
}
