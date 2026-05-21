import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final double progress;
  final String? timeLeft;
  final List<String>? images;
  final IconData icon;
  final double width;
  final double? height;
  final bool showProgress;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    required this.icon,
    this.timeLeft,
    this.images,
    this.width = 300,
    this.height,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF23393E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF23393E).withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23393E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showProgress) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageProvider.translate('progress_label'),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white38,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF23393E),
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              // Participant avatars
              if (images != null && images!.isNotEmpty)
                SizedBox(
                  height: 24,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: images!.length > 4 ? 4 : images!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsetsDirectional.only(end: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF90A4AE),
                          backgroundImage: NetworkImage(images![index]),
                          onBackgroundImageError: (_, __) {},
                        ),
                      );
                    },
                  ),
                )
              else
                Row(
                  children: List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsetsDirectional.only(end: 4),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              if (timeLeft != null)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeLeft!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
