import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import '../../../services/api_service.dart';
import '../../../models/user_model.dart';

class CreateProjectDialog extends StatefulWidget {
  final VoidCallback? onProjectCreated;

  const CreateProjectDialog({super.key, this.onProjectCreated});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();

  static void show(BuildContext context, {VoidCallback? onProjectCreated}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
      pageBuilder: (ctx, anim, anim2) {
        return CreateProjectDialog(onProjectCreated: onProjectCreated);
      },
    );
  }
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final customSkillController = TextEditingController();
  final inviteController = TextEditingController();
  String visibility = 'public';
  List<String> selectedSkills = [];
  List<String> invitedMembers = [];
  bool isCreating = false;

  String tr(String en, String ar) {
    return Provider.of<LanguageProvider>(context).isArabic ? ar : en;
  }

  final availableSkills = [
    'Flutter',
    'Laravel',
    'Vue.js',
    'React',
    'Node.js',
    'Python',
    'Django',
    'Java',
    'Kotlin',
    'Swift',
    'TypeScript',
    'PHP',
    'Go',
    'Rust',
    'C++',
    'Docker',
    'AWS',
    'Firebase',
    'PostgreSQL',
    'MongoDB',
    'Figma',
    'UI/UX',
    'DevOps',
    'Machine Learning',
  ];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    customSkillController.dispose();
    inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEA),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        tr('Projects', 'المشاريع'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Provider.of<LanguageProvider>(context).isArabic
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      tr('Create New', 'إنشاء جديد'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('Create New Project', 'إنشاء مشروع جديد'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(
                              'Define the vision and assemble your team to\nget started.',
                              'حدد رؤية المشروع واجمع فريقك للبدء بالعمل.',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            tr('Discard\nDraft', 'تجاهل\nالمسودة'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isCreating ? null : _createProject,
                          icon: isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.rocket_launch, size: 18),
                          label: Text(
                            tr('Create\nProject', 'إنشاء\nالمشروع'),
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23393E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildProjectIdentityCard(),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildVisibilityCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildInviteTeamCard()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createProject() async {
    if (nameController.text.isEmpty) return;
    setState(() => isCreating = true);
    final result = await ApiService.createProject({
      'name': nameController.text,
      'description': descriptionController.text,
      'visibility': visibility,
      'skills': selectedSkills,
    });
    if (result != null && mounted) {
      // Send invitations to added members
      for (final member in invitedMembers) {
        await ApiService.inviteMemberByUsername(result.id, member);
      }
      widget.onProjectCreated?.call();
      Navigator.pop(context);
    } else {
      if (mounted) setState(() => isCreating = false);
    }
  }

  Widget _buildProjectIdentityCard() {
    return _dialogCard(
      icon: Icons.info_outline,
      title: tr('Project Identity', 'هوية المشروع'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dialogLabel(tr('Project Name', 'اسم المشروع')),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: _dialogInput(tr('e.g. Q4 Marketing Strategy', 'مثال: استراتيجية التسويق للربع الرابع')),
          ),
          const SizedBox(height: 20),
          _dialogLabel(tr('Description', 'الوصف')),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: _dialogInput(
              tr(
                'Describe the project goals, scope, and key objectives...',
                'صف أهداف المشروع ونطاقه والغايات الرئيسية...',
              ),
            ),
          ),
          const SizedBox(height: 20),
          _dialogLabel(tr('Skills', 'المهارات المطلوبة')),
          const SizedBox(height: 8),
          if (selectedSkills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSkills
                  .map(
                    (skill) => Chip(
                      label: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFF23393E),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white70,
                      ),
                      onDeleted: () =>
                          setState(() => selectedSkills.remove(skill)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          _buildSkillsPicker(),
        ],
      ),
    );
  }

  Widget _buildSkillsPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Choose skills for your project', 'اختر مهارات لمشروعك'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected
                      ? selectedSkills.remove(skill)
                      : selectedSkills.add(skill);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF23393E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF23393E)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customSkillController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _dialogInput(
                    tr('Add custom skill...', 'إضافة مهارة مخصصة...'),
                  ).copyWith(fillColor: Colors.white),
                  onSubmitted: _addCustomSkill,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addCustomSkill(customSkillController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23393E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(tr('Add', 'إضافة'), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCustomSkill(String val) {
    if (val.trim().isNotEmpty && !selectedSkills.contains(val.trim())) {
      setState(() {
        selectedSkills.add(val.trim());
        customSkillController.clear();
      });
    }
  }

  Widget _buildVisibilityCard() {
    return _dialogCard(
      icon: Icons.visibility_outlined,
      title: tr('Visibility', 'الرؤية والخصوصية'),
      child: Column(
        children: [
          _visibilityOption(
            title: tr('Public', 'عام'),
            subtitle: tr('Visible to everyone in the organization', 'مرئي للجميع في المؤسسة'),
            icon: Icons.public,
            value: 'public',
            onChanged: (val) => setState(() => visibility = val!),
          ),
          const SizedBox(height: 12),
          _visibilityOption(
            title: tr('Private', 'خاص'),
            subtitle: tr('Only invited team members can access', 'يمكن للأعضاء المدعوين فقط الوصول إليه'),
            icon: Icons.lock_outline,
            value: 'private',
            onChanged: (val) => setState(() => visibility = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteTeamCard() {
    return _dialogCard(
      icon: Icons.group_add_outlined,
      title: tr('Invite Team', 'دعوة فريق العمل'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Search by Username or Email', 'البحث عن طريق اسم المستخدم أو البريد الإلكتروني'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Autocomplete<User>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<User>.empty();
                    }
                    return await ApiService.searchUsers(textEditingValue.text);
                  },
                  displayStringForOption: (User option) => option.username,
                  onSelected: (User selection) {
                    if (!invitedMembers.contains(selection.username)) {
                      setState(() {
                        invitedMembers.add(selection.username);
                      });
                    }
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Update our inviteController with the autocomplete's controller so Add button works
                    inviteController.value = controller.value;
                    controller.addListener(() {
                      inviteController.text = controller.text;
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(fontSize: 13),
                      decoration: _dialogInput(tr('e.g. @sarah_dev or email...', 'مثال: @sarah_dev أو البريد الإلكتروني...')).copyWith(
                        prefixIcon: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      onSubmitted: (value) {
                        onFieldSubmitted();
                        _addMember();
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 300,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final User option = options.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: option.profile?.profileImage != null
                                      ? NetworkImage(option.profile!.profileImage!)
                                      : null,
                                  backgroundColor: const Color(0xFF23393E),
                                  child: option.profile?.profileImage == null
                                      ? Text(
                                          option.username.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        )
                                      : null,
                                ),
                                title: Text(option.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('@${option.username}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23393E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(tr('Add', 'إضافة')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...invitedMembers.map((member) => _buildMemberItem(member)),
        ],
      ),
    );
  }

  void _addMember() {
    final val = inviteController.text.trim().replaceAll('@', '');
    if (val.isNotEmpty && !invitedMembers.contains(val)) {
      setState(() {
        invitedMembers.add(val);
        inviteController.clear();
      });
    }
  }

  Widget _buildMemberItem(String member) {
    final initial = member.length >= 2
        ? member.substring(0, 2).toUpperCase()
        : member.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF23393E),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '@$member',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => invitedMembers.remove(member)),
            child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _dialogCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF23393E)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _dialogLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _dialogInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF23393E), width: 1.5),
      ),
    );
  }

  Widget _visibilityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == visibility;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F5F3) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF23393E) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: visibility,
              onChanged: onChanged,
              activeColor: const Color(0xFF23393E),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
