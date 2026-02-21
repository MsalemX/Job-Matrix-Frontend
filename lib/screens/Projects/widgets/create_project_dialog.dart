import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

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
                        'Projects',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Text(
                      'Create New',
                      style: TextStyle(
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Project',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Define the vision and assemble your team to\nget started.',
                            style: TextStyle(
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
                          child: const Text(
                            'Discard\nDraft',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                          label: const Text(
                            'Create\nProject',
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
      widget.onProjectCreated?.call();
      Navigator.pop(context);
    } else {
      if (mounted) setState(() => isCreating = false);
    }
  }

  Widget _buildProjectIdentityCard() {
    return _dialogCard(
      icon: Icons.info_outline,
      title: 'Project Identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dialogLabel('Project Name'),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: _dialogInput('e.g. Q4 Marketing Strategy'),
          ),
          const SizedBox(height: 20),
          _dialogLabel('Description'),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: _dialogInput(
              'Describe the project goals, scope, and key objectives...',
            ),
          ),
          const SizedBox(height: 20),
          _dialogLabel('Skills'),
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
            'Choose skills for your project',
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
                    'Add custom skill...',
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
                child: const Text('Add', style: TextStyle(fontSize: 12)),
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
      title: 'Visibility',
      child: Column(
        children: [
          _visibilityOption(
            title: 'Public',
            subtitle: 'Visible to everyone in the organization',
            icon: Icons.public,
            value: 'public',
            onChanged: (val) => setState(() => visibility = val!),
          ),
          const SizedBox(height: 12),
          _visibilityOption(
            title: 'Private',
            subtitle: 'Only invited team members can access',
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
      title: 'Invite Team',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search by Username',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inviteController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _dialogInput('e.g. @sarah_dev').copyWith(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
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
                child: const Text('Add'),
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
