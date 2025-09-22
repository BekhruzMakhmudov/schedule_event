import 'package:flutter/material.dart';
import 'package:schedule_event/l10n/app_localizations.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/color_mapper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  bool _loading = true;
  List<Map<String, Object?>> _items = [];

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _notificationService.getDeliveredNotifications();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    await _load();
  }

  Future<void> _markAsRead(int id) async {
    await _notificationService.markAsRead(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notification),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              AppLocalizations.of(context)!.markAllRead,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
    child: _loading
      ? const Center(child: CircularProgressIndicator())
      : _items.isEmpty
        ? Center(child: Text(AppLocalizations.of(context)!.noNotifications))
        : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = _items[index];
                      final id = row['id'] as int;
                      final title = (row['title'] as String?) ?? '';
                      final body = (row['body'] as String?) ?? '';
                      final isRead = ((row['isRead'] as int?) ?? 0) == 1;
                      final deliveredAt = DateTime.fromMillisecondsSinceEpoch(
                        (row['deliveredAt'] as int?) ?? 0,
                      );
                      final colorName = (row['colorName'] as String?) ?? 'blue';
                      final baseColor = ColorMapper.stringToColor(colorName);
                      final cardBg = baseColor.withAlpha(isRead ? 30 : 60);
                      final borderColor = baseColor.withAlpha(120);

                      return Material(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: baseColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (body.isNotEmpty)
                                  Text(
                                    body,
                                    style: TextStyle(
                                      color: baseColor,
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(deliveredAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: baseColor,
                                  ),
                                ),
                              ],
                            ),
                            trailing: TextButton(
                              onPressed: () => _markAsRead(id),
                              child: Text(
                                AppLocalizations.of(context)!.markRead,
                                style: TextStyle(color: baseColor),
                              ),
                            ),
                            onTap: () => _markAsRead(id),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
