import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/preview_session_controller.dart';
import '../notifications/push_notification_service.dart';
import '../onboarding/profile_status_repository.dart';
import 'models/beacon_item.dart';
import 'models/gathering_item.dart';
import 'models/post_item.dart';
import 'repositories/home_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  void _openTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screens = [
      _DashboardTab(
        onOpenBoard: () => _openTab(1),
        onOpenGatherings: () => _openTab(2),
        onOpenQuietRoom: () => _openTab(3),
        onOpenAllTools: () => _openAllToolsSheet(context),
        onOpenBeacon: () => _openTab(4),
      ),
      _BoardTab(),
      _GatheringsTab(),
      _QuietRoomTab(),
      _BeaconTab(),
    ];

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF31443F).withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return theme.textTheme.labelSmall?.copyWith(
                  fontSize: isSelected ? 10.5 : 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.1,
                );
              }),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 72,
              selectedIndex: _selectedTab,
              indicatorColor: colorScheme.surfaceContainerHighest,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.forum_rounded), label: 'Board'),
                NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Gatherings'),
                NavigationDestination(icon: Icon(Icons.room_preferences_rounded), label: 'Quiet'),
                NavigationDestination(icon: Icon(Icons.explore_rounded), label: 'Beacon'),
              ],
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F1E6),
              Color(0xFFE9EFE8),
              Color(0xFFDDE8F4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('CHURCHCIRCLE', style: theme.textTheme.labelMedium),
                    ),
                    const Spacer(),
                    if (PreviewSessionController.instance.isActive)
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        child: IconButton(
                          tooltip: 'Exit preview mode',
                          onPressed: () {
                            PreviewSessionController.instance.disable();
                          },
                          icon: Icon(Icons.logout_rounded, color: colorScheme.primary),
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        child: IconButton(
                          tooltip: 'Notification settings',
                          onPressed: () => _openNotificationSettings(context),
                          icon: Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: screens,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openNotificationSettings(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NotificationSettingsSheet(),
  );
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.onOpenBoard,
    required this.onOpenGatherings,
    required this.onOpenQuietRoom,
    required this.onOpenAllTools,
    required this.onOpenBeacon,
  });

  final VoidCallback onOpenBoard;
  final VoidCallback onOpenGatherings;
  final VoidCallback onOpenQuietRoom;
  final VoidCallback onOpenAllTools;
  final VoidCallback onOpenBeacon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _HeroPanel(theme: theme, onOpenBoard: onOpenBoard),
              const SizedBox(height: 18),
              const _MemberCornerCard(),
              const SizedBox(height: 18),
              _NextGatheringCard(theme: theme),
              const SizedBox(height: 18),
              _BeaconDashboardCard(onOpenBeacon: onOpenBeacon),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Built for real church life', actionLabel: 'View all', onPressed: onOpenAllTools),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: [
                  _FeatureCard(
                    title: 'Circle Board',
                    subtitle: 'Prayer, updates, and practical help in one calm feed.',
                    icon: Icons.forum_rounded,
                    tint: Color(0xFFDDEDE6),
                    onPressed: onOpenBoard,
                  ),
                  _FeatureCard(
                    title: 'Gatherings',
                    subtitle: 'Friday prayer, youth night, and links that are easy to find.',
                    icon: Icons.event_available_rounded,
                    tint: Color(0xFFF2E3D7),
                    onPressed: onOpenGatherings,
                  ),
                  _FeatureCard(
                    title: 'Quiet Room',
                    subtitle: 'Anonymous burdens with no replies, reactions, or exposure.',
                    icon: Icons.nightlight_round,
                    tint: Color(0xFFE5E1F0),
                    onPressed: onOpenQuietRoom,
                  ),
                  _FeatureCard(
                    title: 'Beacon',
                    subtitle: 'Safe nearby connection without exposing exact location.',
                    icon: Icons.explore_rounded,
                    tint: Color(0xFFDCE8F5),
                    onPressed: onOpenBeacon,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'This week feels human', actionLabel: 'Why it matters', onPressed: () => _openWhyItMattersSheet(context)),
              const SizedBox(height: 12),
              const _RhythmPanel(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _BoardTab extends StatelessWidget {
  const _BoardTab();

  @override
  Widget build(BuildContext context) {
    return const _SectionScaffold(
      title: 'Circle Board',
      subtitle: 'Shared life, practical help, and prayer without feed chaos.',
      child: _BoardList(),
    );
  }
}

class _GatheringsTab extends StatelessWidget {
  const _GatheringsTab();

  @override
  Widget build(BuildContext context) {
    return const _SectionScaffold(
      title: 'Gatherings',
      subtitle: 'One place for times, links, and recurring church rhythm.',
      child: _GatheringsList(),
    );
  }
}

class _QuietRoomTab extends StatelessWidget {
  const _QuietRoomTab();

  @override
  Widget build(BuildContext context) {
    return const _SectionScaffold(
      title: 'Quiet Room',
      subtitle: 'A private, anonymous place to release a burden without replies or exposure.',
      child: _QuietRoomPanel(),
    );
  }
}

class _BeaconTab extends StatelessWidget {
  const _BeaconTab();

  @override
  Widget build(BuildContext context) {
    return const _SectionScaffold(
      title: 'Beacon',
      subtitle: 'Opt-in nearby presence using coarse locality only, never an exact address.',
      child: _BeaconPanel(),
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  const _SectionScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BoardList extends StatefulWidget {
  const _BoardList();

  @override
  State<_BoardList> createState() => _BoardListState();
}

class _BoardListState extends State<_BoardList> {
  final _repository = const HomeRepository();
  late Future<List<PostItem>> _postsFuture;
  RealtimeChannel? _postsChannel;

  @override
  void initState() {
    super.initState();
    _postsFuture = _repository.fetchPosts();
    _attachRealtime();
  }

  Future<void> _attachRealtime() async {
    _postsChannel = await _repository.subscribeToBoardChanges(
      onChange: () {
        if (!mounted) {
          return;
        }
        _refreshPosts();
      },
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _repository.fetchPosts();
    });
    await _postsFuture;
  }

  @override
  void dispose() {
    final channel = _postsChannel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostItem>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _StateMessage(
            title: 'Unable to load the board',
            body: 'Check your church membership setup or `DEV_CHURCH_ID`, then try again.',
          );
        }

        final posts = snapshot.data ?? const [];
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: posts.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _PostComposerCard(
                repository: _repository,
                onPosted: _refreshPosts,
              );
            }

            if (posts.isEmpty) {
              return const _StateMessage(
                title: 'No posts yet',
                body: 'When members start sharing updates, prayers, and offers, they will appear here.',
              );
            }

            final post = posts[index - 1];
            return _PostCard(
              postId: post.id,
              author: post.author,
              time: _timeLabel(post.createdAt),
              category: _categoryLabel(post.category),
              body: post.body,
            );
          },
        );
      },
    );
  }
}

class _PostComposerCard extends StatefulWidget {
  const _PostComposerCard({
    required this.repository,
    required this.onPosted,
  });

  final HomeRepository repository;
  final Future<void> Function() onPosted;

  @override
  State<_PostComposerCard> createState() => _PostComposerCardState();
}

class _PostComposerCardState extends State<_PostComposerCard> {
  final _bodyController = TextEditingController();
  String _selectedCategory = HomeRepository.boardCategories.first;
  bool _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await widget.repository.createPost(
        category: _selectedCategory,
        body: _bodyController.text,
      );
      _bodyController.clear();
      await widget.onPosted();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Shared with the church.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException ? error.message : 'Unable to share your post right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share with the church', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HomeRepository.boardCategories
                  .map(
                    (category) => ChoiceChip(
                      label: Text(
                        _categoryLabel(category),
                        style: TextStyle(
                          color: _selectedCategory == category ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurface,
                        ),
                      ),
                      selected: _selectedCategory == category,
                      selectedColor: theme.colorScheme.secondaryContainer,
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: _selectedCategory == category
                            ? theme.colorScheme.secondaryContainer
                            : theme.colorScheme.outlineVariant,
                      ),
                      onSelected: _isSubmitting
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share an update, prayer, need, offer, or word of encouragement...',
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Sharing...' : 'Post to Circle Board'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GatheringsList extends StatefulWidget {
  const _GatheringsList();

  @override
  State<_GatheringsList> createState() => _GatheringsListState();
}

class _GatheringsListState extends State<_GatheringsList> {
  final _repository = const HomeRepository();
  final _profileRepository = ProfileStatusRepository();
  late Future<List<GatheringItem>> _gatheringsFuture;
  late Future<bool> _canManageFuture;

  @override
  void initState() {
    super.initState();
    _gatheringsFuture = _repository.fetchGatherings();
    _canManageFuture = _loadManagePermission();
  }

  Future<bool> _loadManagePermission() async {
    if (PreviewSessionController.instance.isActive) {
      return true;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    return _profileRepository.canManageChurchGatherings(userId);
  }

  Future<void> _refreshGatherings() async {
    setState(() {
      _gatheringsFuture = _repository.fetchGatherings();
      _canManageFuture = _loadManagePermission();
    });
    await _gatheringsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canManageFuture,
      builder: (context, permissionSnapshot) {
        final canManage = permissionSnapshot.data ?? false;

        return FutureBuilder<List<GatheringItem>>(
          future: _gatheringsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done || permissionSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _StateMessage(
                title: 'Unable to load gatherings',
                body: 'Check your church membership setup or `DEV_CHURCH_ID`, then try again.',
              );
            }

            final gatherings = snapshot.data ?? const [];
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: gatherings.length + (canManage ? 1 : 0) + (gatherings.isEmpty ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var cursor = 0;
                if (canManage) {
                  if (index == cursor) {
                    return _GatheringComposerCard(
                      repository: _repository,
                      onCreated: _refreshGatherings,
                    );
                  }
                  cursor += 1;
                }

                if (gatherings.isEmpty) {
                  if (index == cursor) {
                    return const _StateMessage(
                      title: 'No gatherings yet',
                      body: 'Recurring meetings and join links will appear here once your church adds them.',
                    );
                  }
                }

                final gathering = gatherings[index - cursor];
                return _GatheringRow(
                  title: gathering.title,
                  schedule: _scheduleLabel(gathering.schedule),
                  detail: gathering.detail,
                  accent: gathering.isOnline ? const Color(0xFFDDEDE6) : const Color(0xFFF2E3D7),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GatheringComposerCard extends StatefulWidget {
  const _GatheringComposerCard({
    required this.repository,
    required this.onCreated,
  });

  final HomeRepository repository;
  final Future<void> Function() onCreated;

  @override
  State<_GatheringComposerCard> createState() => _GatheringComposerCardState();
}

class _GatheringComposerCardState extends State<_GatheringComposerCard> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationLabelController = TextEditingController();
  final _joinUrlController = TextEditingController();
  String _locationType = HomeRepository.gatheringLocationTypes.first;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 1));
  bool _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationLabelController.dispose();
    _joinUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await widget.repository.createGathering(
        title: _titleController.text,
        description: _descriptionController.text,
        startsAt: _startsAt,
        locationType: _locationType,
        locationLabel: _locationLabelController.text,
        joinUrl: _joinUrlController.text,
      );
      _titleController.clear();
      _descriptionController.clear();
      _locationLabelController.clear();
      _joinUrlController.clear();
      await widget.onCreated();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Gathering created.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException ? error.message : 'Unable to create the gathering right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create church gathering', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _locationType,
              items: HomeRepository.gatheringLocationTypes
                  .map((value) => DropdownMenuItem(value: value, child: Text(_locationTypeLabel(value))))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _locationType = value;
                        });
                      }
                    },
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationLabelController,
              decoration: InputDecoration(
                labelText: _locationType == 'online' ? 'Location note (optional)' : 'Location',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _joinUrlController,
              decoration: const InputDecoration(labelText: 'Join URL (optional)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickDateTime,
              icon: const Icon(Icons.schedule_rounded),
              label: Text('Starts ${_scheduleLabel(_startsAt)}'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.event_available_rounded),
              label: Text(_isSubmitting ? 'Creating...' : 'Create gathering'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietRoomPanel extends StatefulWidget {
  const _QuietRoomPanel();

  @override
  State<_QuietRoomPanel> createState() => _QuietRoomPanelState();
}

class _QuietRoomPanelState extends State<_QuietRoomPanel> {
  final _repository = const HomeRepository();
  final _controller = TextEditingController();
  late Future<List<QuietRoomEntryItem>> _entriesFuture;
  bool _isSubmitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _repository.fetchQuietRoomEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _entriesFuture = _repository.fetchQuietRoomEntries();
    });
    await _entriesFuture;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await _repository.createQuietRoomEntry(content: _controller.text);
      _controller.clear();
      await _refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Shared anonymously.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException
            ? error.message
            : 'Unable to share in the Quiet Room right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<QuietRoomEntryItem>>(
      future: _entriesFuture,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <QuietRoomEntryItem>[];

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Write without being known.', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    'No replies. No reactions. No names attached. This space exists for witness, not discussion.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _controller,
                    maxLines: 7,
                    decoration: InputDecoration(
                      hintText: 'Share a prayer, burden, fear, or gratitude...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      child: Text(_isSubmitting ? 'Sharing...' : 'Share anonymously'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: CircularProgressIndicator())
            else if (entries.isEmpty)
              const _StateMessage(
                title: 'Quiet Room is empty',
                body: 'When someone shares a private burden or prayer, it will appear here without replies or reactions.',
              )
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuietRoomEntryCard(entry: entry),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BeaconPanel extends StatefulWidget {
  const _BeaconPanel();

  @override
  State<_BeaconPanel> createState() => _BeaconPanelState();
}

class _BeaconPanelState extends State<_BeaconPanel> {
  final _repository = const HomeRepository();
  final _localityController = TextEditingController();
  final _areaHintController = TextEditingController();
  late Future<List<BeaconItem>> _beaconsFuture;
  bool _isSubmitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _beaconsFuture = _repository.fetchBeacons();
  }

  @override
  void dispose() {
    _localityController.dispose();
    _areaHintController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _beaconsFuture = _repository.fetchBeacons();
    });
    await _beaconsFuture;
  }

  Future<void> _submitBeacon() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await _repository.upsertBeacon(
        locality: _localityController.text,
        areaHint: _areaHintController.text,
      );
      _localityController.clear();
      _areaHintController.clear();
      await _refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Your beacon is live with coarse location only.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException ? error.message : 'Unable to place your beacon right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _toggleVisibility(bool isVisible) async {
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await _repository.updateBeaconVisibility(isVisible: isVisible);
      await _refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = isVisible ? 'Your beacon is visible to your church.' : 'Your beacon is now hidden.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException ? error.message : 'Unable to update visibility right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<BeaconItem>>(
      future: _beaconsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _StateMessage(
            title: 'Unable to load Beacon',
            body: 'Run the Beacon migration and check your church membership, then try again.',
          );
        }

        final beacons = snapshot.data ?? const <BeaconItem>[];
        final ownBeacon = beacons.where((item) => item.isOwn).cast<BeaconItem?>().firstWhere((item) => item != null, orElse: () => null);
        final visibleBeacons = beacons.where((item) => item.isVisible).toList();
        final nearbyBeacons = _sortedBeacons(visibleBeacons, ownBeacon);

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _BeaconIntroCard(
              ownBeacon: ownBeacon,
              isBusy: _isSubmitting,
              localityController: _localityController,
              areaHintController: _areaHintController,
              onSubmit: _submitBeacon,
              onToggleVisibility: ownBeacon == null ? null : () => _toggleVisibility(!ownBeacon.isVisible),
              message: _message,
            ),
            const SizedBox(height: 16),
            _BeaconMapCard(beacons: visibleBeacons),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nearby beacons', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      ownBeacon == null
                          ? 'You can already explore the church map. Add your own beacon to see who sits closest to you in the area.'
                          : 'These are anonymous nearby members around your coarse beacon. Identity sharing and connect requests come next.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    if (nearbyBeacons.isEmpty)
                      const _StateMessage(
                        title: 'No visible beacons yet',
                        body: 'Once members opt in, nearby anonymous dots will appear here.',
                      )
                    else
                      ...nearbyBeacons.take(4).map(
                        (beacon) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BeaconListRow(
                            beacon: beacon,
                            distanceLabel: ownBeacon == null ? null : _distanceLabel(ownBeacon, beacon),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.theme, required this.onOpenBoard});

  final ThemeData theme;
  final VoidCallback onOpenBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your church, between Sundays.', style: theme.textTheme.displayLarge),
          const SizedBox(height: 14),
          Text(
            'A calm, modern space for shared life, gatherings, anonymous prayer, and real connection across the congregation.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenBoard,
                icon: const Icon(Icons.forum_rounded),
                label: const Text('Open Circle Board'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openProfileEditor(context),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openProfileEditor(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ProfileEditorSheet(),
  );
}

class _MemberCornerCard extends StatefulWidget {
  const _MemberCornerCard();

  @override
  State<_MemberCornerCard> createState() => _MemberCornerCardState();
}

class _MemberCornerCardState extends State<_MemberCornerCard> {
  final _repository = ProfileStatusRepository();
  late Future<bool> _canManageFuture;
  late Future<bool> _canStartChurchFuture;
  Future<List<ChurchInviteDetails>>? _recentInvitesFuture;
  ChurchInviteDetails? _latestInvite;
  bool _isGenerating = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _canManageFuture = _loadPermission();
    _canStartChurchFuture = _repository.canStartChurch();
    _recentInvitesFuture = _loadRecentInvites();
  }

  Future<bool> _loadPermission() async {
    if (PreviewSessionController.instance.isActive) {
      return true;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    return _repository.canManageChurchGatherings(userId);
  }

  Future<void> _generateInvite() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _message = 'You need to be signed in before creating invites.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _message = null;
    });

    try {
      final invite = await _repository.createInviteForActiveChurch(userId: userId);
      if (!mounted) {
        return;
      }
      setState(() {
        _latestInvite = invite;
        _recentInvitesFuture = _loadRecentInvites();
        _message = 'Invite code ready to share.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _copyInvite() async {
    final invite = _latestInvite;
    if (invite == null) {
      return;
    }

    final inviteLink = 'churchcircle://join?invite=${invite.code}';
    await Clipboard.setData(ClipboardData(text: '${invite.code}\n$inviteLink'));
    if (!mounted) {
      return;
    }
    setState(() {
      _message = 'Invite code and link copied.';
    });
  }

  Future<List<ChurchInviteDetails>> _loadRecentInvites() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const [];
    }

    return _repository.fetchRecentInvitesForActiveChurch(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<bool>(
      future: Future.wait([_canManageFuture, _canStartChurchFuture]).then((values) => values.first),
      builder: (context, _) {
        return FutureBuilder<bool>(
          future: _canManageFuture,
          builder: (context, manageSnapshot) {
            return FutureBuilder<bool>(
              future: _canStartChurchFuture,
              builder: (context, adoptSnapshot) {
                final canManage = manageSnapshot.data ?? false;
                final canStartChurch = adoptSnapshot.data ?? false;
                final isLoading = manageSnapshot.connectionState != ConnectionState.done || adoptSnapshot.connectionState != ConnectionState.done;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Member Corner', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          canManage
                              ? 'Share an invite code, link, or QR so members can join your church space.'
                              : canStartChurch
                                  ? 'You are approved to start a church space and can also manage invites once it is created.'
                                  : 'Your profile can be updated any time. Invite generation appears here for church admins and leaders.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (isLoading) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (canManage)
                              FilledButton.icon(
                                onPressed: _isGenerating ? null : _generateInvite,
                                icon: const Icon(Icons.link_rounded),
                                label: Text(_isGenerating ? 'Generating...' : 'Generate invite'),
                              ),
                            if (canManage && _latestInvite != null)
                              OutlinedButton.icon(
                                onPressed: _copyInvite,
                                icon: const Icon(Icons.copy_rounded),
                                label: const Text('Copy code and link'),
                              ),
                            if (canStartChurch)
                              OutlinedButton.icon(
                                onPressed: () => _openChurchCreator(context),
                                icon: const Icon(Icons.church_rounded),
                                label: const Text('Start a church'),
                              ),
                          ],
                        ),
                        if (_latestInvite != null) ...[
                          const SizedBox(height: 14),
                          SelectableText(
                            'Code: ${_latestInvite!.code}\nLink: churchcircle://join?invite=${_latestInvite!.code}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: QrImageView(
                              data: 'churchcircle://join?invite=${_latestInvite!.code}',
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                        if (canManage) ...[
                          const SizedBox(height: 16),
                          Text('Recent invites', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 10),
                          FutureBuilder<List<ChurchInviteDetails>>(
                            future: _recentInvitesFuture,
                            builder: (context, inviteSnapshot) {
                              if (inviteSnapshot.connectionState != ConnectionState.done) {
                                return const LinearProgressIndicator();
                              }

                              final invites = inviteSnapshot.data ?? const [];
                              if (invites.isEmpty) {
                                return Text(
                                  'No invites generated yet for this church space.',
                                  style: theme.textTheme.bodyMedium,
                                );
                              }

                              return Column(
                                children: invites
                                    .map(
                                      (invite) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _InviteSummaryRow(invite: invite),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ],
                        if (_message != null) ...[
                          const SizedBox(height: 12),
                          Text(_message!, style: theme.textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _InviteSummaryRow extends StatelessWidget {
  const _InviteSummaryRow({required this.invite});

  final ChurchInviteDetails invite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiresLabel = invite.expiresAt == null
        ? 'No expiry'
        : 'Expires ${_dateLabel(invite.expiresAt!)}';
    final useLabel = invite.maxUses == null
        ? '${invite.useCount ?? 0} uses'
        : '${invite.useCount ?? 0} / ${invite.maxUses} uses';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(invite.code, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$expiresLabel · $useLabel',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

Future<void> _openChurchCreator(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ChurchCreatorSheet(),
  );
}

class _ChurchCreatorSheet extends StatefulWidget {
  const _ChurchCreatorSheet();

  @override
  State<_ChurchCreatorSheet> createState() => _ChurchCreatorSheetState();
}

class _ChurchCreatorSheetState extends State<_ChurchCreatorSheet> {
  final _repository = ProfileStatusRepository();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _countryController = TextEditingController(text: 'IE');
  bool _isSaving = false;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await _repository.createChurchAsAdopter(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        countryCode: _countryController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Church space created. You are now its admin.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Material(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start a church', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'This flow is reserved for approved adopters such as pastors or designated leaders.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Church name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _slugController,
                  decoration: const InputDecoration(labelText: 'Church slug'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Country code'),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _create,
                  icon: const Icon(Icons.church_rounded),
                  label: Text(_isSaving ? 'Creating...' : 'Create church space'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileEditorSheet extends StatefulWidget {
  const _ProfileEditorSheet();

  @override
  State<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  final _repository = ProfileStatusRepository();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _gatheringReminders = true;
  bool _importantChurchUpdates = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _message = 'Sign in to manage notification preferences.';
      });
      return;
    }

    final preferences = await _repository.fetchNotificationPreferences(userId);
    final registration = await PushNotificationService.instance.syncCurrentUser();
    if (!mounted) {
      return;
    }

    setState(() {
      _gatheringReminders = preferences.gatheringReminders;
      _importantChurchUpdates = preferences.importantChurchUpdates;
      _message = registration.message;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _message = 'Sign in to manage notification preferences.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await _repository.saveNotificationPreferences(
        userId: userId,
        gatheringReminders: _gatheringReminders,
        importantChurchUpdates: _importantChurchUpdates,
      );
      final registration = await PushNotificationService.instance.syncCurrentUser();
      if (!mounted) {
        return;
      }
      setState(() {
        _message = registration.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Unable to save notification settings right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Material(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Notification settings', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text(
                        'Keep push limited to essential alerts so ChurchCircle does not become another noisy group chat.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        value: _gatheringReminders,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Gathering reminders'),
                        subtitle: const Text('Upcoming church-wide gathering reminders.'),
                        onChanged: (value) => setState(() {
                          _gatheringReminders = value;
                        }),
                      ),
                      SwitchListTile.adaptive(
                        value: _importantChurchUpdates,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Important church updates'),
                        subtitle: const Text('Rare high-importance alerts from church leaders or admins.'),
                        onChanged: (value) => setState(() {
                          _importantChurchUpdates = value;
                        }),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(_message!, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.notifications_active_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Save notification settings'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfileEditorSheetState extends State<_ProfileEditorSheet> {
  final _repository = ProfileStatusRepository();
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _townController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _displayNameController.dispose();
    _townController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _message = 'You need to be signed in to edit your profile.';
      });
      return;
    }

    final profile = await _repository.fetchProfileDetails(userId);
    if (!mounted) {
      return;
    }

    _fullNameController.text = profile?.fullName ?? '';
    _displayNameController.text = profile?.displayName ?? '';
    _townController.text = profile?.town ?? '';
    _bioController.text = profile?.bio ?? '';

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _message = 'You need to be signed in to edit your profile.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await _repository.saveProfile(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        town: _townController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Profile updated.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Unable to update your profile right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Material(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit profile', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(labelText: 'Display name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _townController,
                        decoration: const InputDecoration(labelText: 'Town or area'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Short intro'),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(_message!, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Save changes'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _NextGatheringCard extends StatelessWidget {
  const _NextGatheringCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GatheringItem>>(
      future: const HomeRepository().fetchGatherings(),
      builder: (context, snapshot) {
        final gatherings = snapshot.data ?? const <GatheringItem>[];
        final nextGathering = gatherings.where((item) => item.schedule.isAfter(DateTime.now())).fold<GatheringItem?>(
          null,
          (current, item) => current == null || item.schedule.isBefore(current.schedule) ? item : current,
        );

        if (snapshot.connectionState != ConnectionState.done) {
          return _StaticGatheringCard(
            theme: theme,
            title: 'Loading gatherings...',
            detail: 'Looking for the next available church rhythm.',
            buttonLabel: 'Join gathering',
            buttonEnabled: false,
          );
        }

        if (nextGathering == null) {
          return _StaticGatheringCard(
            theme: theme,
            title: 'No upcoming gathering yet',
            detail: 'When leaders add a prayer room, Bible study, or special meeting, it will appear here.',
            buttonLabel: 'Join gathering',
            buttonEnabled: false,
          );
        }

        final isJoinDay = DateUtils.isSameDay(DateTime.now(), nextGathering.schedule);
        final canJoin = isJoinDay && nextGathering.isOnline && nextGathering.joinUrl.isNotEmpty;

        return _StaticGatheringCard(
          theme: theme,
          title: nextGathering.title,
          detail: '${_scheduleLabel(nextGathering.schedule)} · ${nextGathering.detail}',
          buttonLabel: canJoin ? 'Join gathering' : 'Available on ${_dayLabel(nextGathering.schedule)}',
          buttonEnabled: canJoin,
        );
      },
    );
  }
}

class _BeaconDashboardCard extends StatefulWidget {
  const _BeaconDashboardCard({required this.onOpenBeacon});

  final VoidCallback onOpenBeacon;

  @override
  State<_BeaconDashboardCard> createState() => _BeaconDashboardCardState();
}

class _BeaconDashboardCardState extends State<_BeaconDashboardCard> {
  final _repository = const HomeRepository();
  late Future<List<BeaconItem>> _beaconsFuture;

  @override
  void initState() {
    super.initState();
    _beaconsFuture = _repository.fetchBeacons();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<BeaconItem>>(
      future: _beaconsFuture,
      builder: (context, snapshot) {
        final beacons = (snapshot.data ?? const <BeaconItem>[]).where((item) => item.isVisible).toList();
        final nearbyCount = beacons.where((item) => !item.isOwn).length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beacon nearby', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          nearbyCount == 0
                              ? 'Turn Beacon on to start seeing anonymous nearby members.'
                              : '$nearbyCount anonymous ${nearbyCount == 1 ? 'beacon is' : 'beacons are'} visible near Dave\'s demo area.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: widget.onOpenBeacon,
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Open'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _BeaconMapSurface(
                beacons: beacons,
                height: 168,
                title: _sharedLocalityLabel(beacons),
                compact: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

String _dayLabel(DateTime value) {
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return dayNames[value.weekday - 1];
}

String _dateLabel(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _locationTypeLabel(String value) {
  switch (value) {
    case 'online':
      return 'Online';
    case 'in_person':
      return 'In person';
    case 'hybrid':
      return 'Hybrid';
  }

  return value;
}

class _StaticGatheringCard extends StatelessWidget {
  const _StaticGatheringCard({
    required this.theme,
    required this.title,
    required this.detail,
    required this.buttonLabel,
    required this.buttonEnabled,
  });

  final ThemeData theme;
  final String title;
  final String detail;
  final String buttonLabel;
  final bool buttonEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT GATHERING',
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.55),
                    disabledForegroundColor: colorScheme.primary.withValues(alpha: 0.75),
                  ),
                  onPressed: buttonEnabled ? () {} : null,
                  child: Text(buttonLabel),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
                icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuietRoomEntryCard extends StatelessWidget {
  const _QuietRoomEntryCard({required this.entry});

  final QuietRoomEntryItem entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Chip(label: Text('Prayer')),
                const Spacer(),
                Text(_timeLabel(entry.createdAt), style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(entry.content, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Seen quietly by the church for prayer, not for replies.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        TextButton(
          onPressed: onPressed,
          child: Text(actionLabel, style: theme.textTheme.labelLarge),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const Spacer(),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openAllToolsSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ToolsOverviewSheet(),
  );
}

Future<void> _openWhyItMattersSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _WhyItMattersSheet(),
  );
}

class _ToolsOverviewSheet extends StatelessWidget {
  const _ToolsOverviewSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardSheet(
      title: 'Current tools',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('These are the tools currently available in the app build.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          const _ToolBullet(title: 'Circle Board', detail: 'Live posts, comments, nested replies, and basic moderation.'),
          const _ToolBullet(title: 'Gatherings', detail: 'Church-wide gatherings with admin or leader creation.'),
          const _ToolBullet(title: 'Quiet Room', detail: 'Anonymous posting with no replies or reactions.'),
          const _ToolBullet(title: 'Member Corner', detail: 'Invite generation, QR sharing, and profile editing entry points.'),
          const _ToolBullet(title: 'Beacon', detail: 'Live anonymous-dot demo with coarse locality and opt-in visibility.'),
        ],
      ),
    );
  }
}

class _WhyItMattersSheet extends StatelessWidget {
  const _WhyItMattersSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardSheet(
      title: 'Why it matters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ChurchCircle is being shaped to reduce noise and make church life easier to carry between Sundays.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          const _ToolBullet(title: 'Pull over push', detail: 'Most spaces are interest-led, not interruption-led.'),
          const _ToolBullet(title: 'Quiet support', detail: 'Quiet Room stays visible but non-interactive.'),
          const _ToolBullet(title: 'Simple shared rhythm', detail: 'Gatherings and invites stay clear without turning into admin software.'),
        ],
      ),
    );
  }
}

class _DashboardSheet extends StatelessWidget {
  const _DashboardSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Material(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolBullet extends StatelessWidget {
  const _ToolBullet({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(text: '$title: ', style: theme.textTheme.titleSmall),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeaconIntroCard extends StatelessWidget {
  const _BeaconIntroCard({
    required this.ownBeacon,
    required this.isBusy,
    required this.localityController,
    required this.areaHintController,
    required this.onSubmit,
    required this.onToggleVisibility,
    required this.message,
  });

  final BeaconItem? ownBeacon;
  final bool isBusy;
  final TextEditingController localityController;
  final TextEditingController areaHintController;
  final VoidCallback onSubmit;
  final VoidCallback? onToggleVisibility;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beacon stays coarse by design', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'This first Beacon release stores only locality and approximate placement. No exact address is written to the database.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (ownBeacon == null) ...[
              TextField(
                controller: localityController,
                decoration: const InputDecoration(labelText: 'Town or locality'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaHintController,
                decoration: const InputDecoration(labelText: 'Area hint (optional)'),
              ),
              const SizedBox(height: 12),
              Text(
                'I understand my locality will be used to place an approximate beacon that other active church members can see.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: isBusy ? null : onSubmit,
                icon: const Icon(Icons.explore_rounded),
                label: Text(isBusy ? 'Placing...' : 'I understand — set my beacon'),
              ),
            ] else ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoPill(label: 'Locality', value: ownBeacon!.locality),
                  _InfoPill(label: 'Area', value: ownBeacon!.areaHint ?? 'Unspecified'),
                  _InfoPill(label: 'Visibility', value: ownBeacon!.isVisible ? 'Visible' : 'Hidden'),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onToggleVisibility,
                icon: Icon(ownBeacon!.isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                label: Text(ownBeacon!.isVisible ? 'Hide my beacon' : 'Show my beacon'),
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _BeaconMapCard extends StatelessWidget {
  const _BeaconMapCard({required this.beacons});

  final List<BeaconItem> beacons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Church map', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Dots are intentionally approximate. They show presence in an area, not a household location.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            _BeaconMapSurface(
              beacons: beacons,
              height: 280,
              title: _sharedLocalityLabel(beacons),
              compact: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BeaconMapSurface extends StatefulWidget {
  const _BeaconMapSurface({
    required this.beacons,
    required this.height,
    required this.title,
    required this.compact,
  });

  final List<BeaconItem> beacons;
  final double height;
  final String title;
  final bool compact;

  @override
  State<_BeaconMapSurface> createState() => _BeaconMapSurfaceState();
}

class _BeaconMapSurfaceState extends State<_BeaconMapSurface> {
  bool _showInfoPanel = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markers = widget.beacons
        .map(
          (beacon) => Marker(
            point: LatLng(beacon.latitude, beacon.longitude),
            width: beacon.isOwn ? 34 : 28,
            height: beacon.isOwn ? 34 : 28,
            child: _BeaconDot(beacon: beacon),
          ),
        )
        .toList();

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _mapCenterFor(widget.beacons),
                initialZoom: widget.compact ? 11.5 : 12.2,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.atensai.mobile',
                ),
                MarkerLayer(markers: markers),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
            if (_showInfoPanel)
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: widget.compact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              setState(() {
                                _showInfoPanel = false;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.close_rounded, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.compact ? 'Anonymous nearby presence' : 'Coarse anonymous dots. Never exact household pins.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${widget.beacons.length} visible', style: theme.textTheme.labelMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeaconDot extends StatelessWidget {
  const _BeaconDot({required this.beacon});

  final BeaconItem beacon;

  @override
  Widget build(BuildContext context) {
    final color = beacon.isOwn ? const Color(0xFF254F45) : const Color(0xFF406C9B);

    return Tooltip(
      message: beacon.isOwn
          ? 'Your beacon'
          : beacon.areaHint == null
              ? 'Anonymous beacon'
              : 'Anonymous beacon near ${beacon.areaHint}',
      child: Container(
        height: beacon.isOwn ? 24 : 20,
        width: beacon.isOwn ? 24 : 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: beacon.isOwn ? 4 : 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _BeaconListRow extends StatelessWidget {
  const _BeaconListRow({required this.beacon, required this.distanceLabel});

  final BeaconItem beacon;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: beacon.isOwn ? const Color(0xFF254F45) : const Color(0xFF406C9B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(beacon.isOwn ? 'You' : (beacon.isDemo ? 'Anonymous member · demo' : 'Anonymous member'), style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  [beacon.locality, if ((beacon.areaHint?.isNotEmpty ?? false)) beacon.areaHint!].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (distanceLabel != null) Text(distanceLabel!, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value', style: theme.textTheme.labelLarge),
    );
  }
}

List<BeaconItem> _sortedBeacons(List<BeaconItem> beacons, BeaconItem? ownBeacon) {
  final filtered = beacons.where((item) => !item.isOwn).toList();
  if (ownBeacon == null) {
    return filtered;
  }

  filtered.sort((left, right) {
    final leftDistance = _distanceScore(ownBeacon, left);
    final rightDistance = _distanceScore(ownBeacon, right);
    return leftDistance.compareTo(rightDistance);
  });
  return filtered;
}

double _distanceScore(BeaconItem origin, BeaconItem candidate) {
  final latDistance = origin.latitude - candidate.latitude;
  final lngDistance = origin.longitude - candidate.longitude;
  return (latDistance * latDistance) + (lngDistance * lngDistance);
}

String _distanceLabel(BeaconItem origin, BeaconItem candidate) {
  final score = _distanceScore(origin, candidate);
  if (score < 140) {
    return 'Very close';
  }
  if (score < 500) {
    return 'Nearby';
  }
  return 'Further out';
}

String _sharedLocalityLabel(List<BeaconItem> beacons) {
  if (beacons.isEmpty) {
    return 'Your area';
  }

  final first = beacons.first.locality.trim();
  final same = beacons.every((item) => item.locality.trim() == first);
  return same && first.isNotEmpty ? first : 'Church area';
}

LatLng _mapCenterFor(List<BeaconItem> beacons) {
  if (beacons.isEmpty) {
    return const LatLng(53.3200, -6.3900);
  }

  final latitudes = beacons.map((item) => item.latitude).toList();
  final longitudes = beacons.map((item) => item.longitude).toList();
  final avgLat = latitudes.reduce((a, b) => a + b) / latitudes.length;
  final avgLng = longitudes.reduce((a, b) => a + b) / longitudes.length;
  return LatLng(avgLat, avgLng);
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.postId,
    required this.author,
    required this.time,
    required this.category,
    required this.body,
  });

  final String postId;
  final String author;
  final String time;
  final String category;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(author.characters.first),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author, style: theme.textTheme.titleMedium),
                      Text(time, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Chip(label: Text(category)),
              ],
            ),
            const SizedBox(height: 14),
            Text(body, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            _PostCommentsSection(postId: postId),
          ],
        ),
      ),
    );
  }
}

class _PostCommentsSection extends StatefulWidget {
  const _PostCommentsSection({required this.postId});

  final String postId;

  @override
  State<_PostCommentsSection> createState() => _PostCommentsSectionState();
}

class _PostCommentsSectionState extends State<_PostCommentsSection> {
  final _repository = const HomeRepository();
  final _profileRepository = ProfileStatusRepository();
  final _controller = TextEditingController();
  late Future<List<PostCommentItem>> _commentsFuture;
  late Future<bool> _canModerateFuture;
  RealtimeChannel? _commentsChannel;
  bool _isSubmitting = false;
  PostCommentItem? _replyTarget;
  PostCommentItem? _editingComment;
  String? _message;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _repository.fetchComments(widget.postId);
    _canModerateFuture = _loadCanModerate();
    _attachRealtime();
  }

  Future<bool> _loadCanModerate() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }
    return _profileRepository.canManageChurchGatherings(userId);
  }

  Future<void> _attachRealtime() async {
    _commentsChannel = await _repository.subscribeToCommentChanges(
      postId: widget.postId,
      onChange: () {
        if (!mounted) {
          return;
        }
        _refresh();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    final channel = _commentsChannel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _commentsFuture = _repository.fetchComments(widget.postId);
    });
    await _commentsFuture;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      if (_editingComment != null) {
        await _repository.updateComment(
          commentId: _editingComment!.id,
          body: _controller.text,
        );
      } else {
        await _repository.createComment(
          postId: widget.postId,
          body: _controller.text,
          parentCommentId: _replyTarget?.id,
        );
      }
      _controller.clear();
      await _refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _replyTarget = null;
        _editingComment = null;
        _message = 'Reply saved.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error is HomeRepositoryException ? error.message : 'Unable to post your reply right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<PostCommentItem>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? const <PostCommentItem>[];
        final rootComments = comments.where((comment) => comment.parentCommentId == null).toList();
        final repliesByParent = <String, List<PostCommentItem>>{};
        for (final comment in comments.where((comment) => comment.parentCommentId != null)) {
          repliesByParent.putIfAbsent(comment.parentCommentId!, () => []).add(comment);
        }

        return FutureBuilder<bool>(
          future: _canModerateFuture,
          builder: (context, moderationSnapshot) {
            final canModerate = moderationSnapshot.data ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Replies', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator()
            else if (comments.isEmpty)
              Text(
                'No replies yet. Be the first to respond.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: rootComments
                    .map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommentThread(
                          comment: comment,
                          replies: repliesByParent[comment.id] ?? const [],
                          canModerate: canModerate,
                          onReply: () {
                            setState(() {
                              _editingComment = null;
                              _replyTarget = comment;
                            });
                          },
                          onReplyToReply: (reply) {
                            setState(() {
                              _editingComment = null;
                              _replyTarget = reply;
                            });
                          },
                          onEdit: (target) {
                            setState(() {
                              _editingComment = target;
                              _replyTarget = null;
                              _controller.text = target.body;
                            });
                          },
                          onDelete: (target) async {
                            await _repository.deleteComment(commentId: target.id);
                            await _refresh();
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              if (_editingComment?.id == target.id) {
                                _editingComment = null;
                                _controller.clear();
                              }
                              if (_replyTarget?.id == target.id) {
                                _replyTarget = null;
                              }
                              _message = 'Reply removed.';
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            if (_editingComment != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editing reply from ${_editingComment!.author}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingComment = null;
                          _controller.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ] else if (_replyTarget != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to ${_replyTarget!.author}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _replyTarget = null;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _editingComment != null ? 'Edit reply' : null,
                hintText: _replyTarget == null
                    ? (_editingComment == null ? 'Write a supportive reply...' : 'Update your reply...')
                    : 'Write a reply to ${_replyTarget!.author}...',
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: _isSubmitting ? null : _submit,
              icon: Icon(_editingComment == null ? Icons.reply_rounded : Icons.save_rounded),
              label: Text(_isSubmitting ? 'Saving...' : (_editingComment == null ? 'Reply' : 'Save changes')),
            ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    required this.replies,
    required this.canModerate,
    required this.onReply,
    required this.onReplyToReply,
    required this.onEdit,
    required this.onDelete,
  });

  final PostCommentItem comment;
  final List<PostCommentItem> replies;
  final bool canModerate;
  final VoidCallback onReply;
  final ValueChanged<PostCommentItem> onReplyToReply;
  final ValueChanged<PostCommentItem> onEdit;
  final ValueChanged<PostCommentItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentRow(
          comment: comment,
          canModerate: canModerate,
          onReply: onReply,
          onEdit: () => onEdit(comment),
          onDelete: () => onDelete(comment),
        ),
        if (replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              children: replies
                  .map(
                    (reply) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CommentRow(
                        comment: reply,
                        isNested: true,
                        canModerate: canModerate,
                        onReply: () => onReplyToReply(reply),
                        onEdit: () => onEdit(reply),
                        onDelete: () => onDelete(reply),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.canModerate,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    this.isNested = false,
  });

  final PostCommentItem comment;
  final bool canModerate;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isNested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final canManageThisComment = canModerate || currentUserId == comment.authorId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNested
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(comment.author, style: theme.textTheme.titleSmall)),
              const SizedBox(width: 8),
              Text(_timeLabel(comment.createdAt), style: theme.textTheme.bodySmall),
              if (canManageThisComment)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onReply,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            icon: const Icon(Icons.reply_rounded, size: 16),
            label: const Text('Reply'),
          ),
        ],
      ),
    );
  }
}

class _GatheringRow extends StatelessWidget {
  const _GatheringRow({
    required this.title,
    required this.schedule,
    required this.detail,
    required this.accent,
  });

  final String title;
  final String schedule;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 64,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(schedule, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(detail, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmPanel extends StatelessWidget {
  const _RhythmPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _RhythmRow(
              title: 'Shared life',
              detail: 'A prayer request, a practical ask, or a small testimony can live beyond the Sunday handshake.',
            ),
            SizedBox(height: 16),
            _RhythmRow(
              title: 'Quiet support',
              detail: 'Secret prayers can be carried safely without exposing the person behind them.',
            ),
            SizedBox(height: 16),
            _RhythmRow(
              title: 'Easy access',
              detail: 'Gathering times and links stay visible instead of disappearing into chat noise.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmRow extends StatelessWidget {
  const _RhythmRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(detail, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String _timeLabel(DateTime value) {
  final difference = DateTime.now().difference(value);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes.clamp(1, 59)} mins ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }

  return 'Earlier';
}

String _categoryLabel(String value) {
  switch (value) {
    case 'life_update':
      return 'Life Update';
    case 'prayer':
      return 'Prayer';
    case 'ask':
      return 'Ask';
    case 'offer':
      return 'Offer';
    case 'encouragement':
      return 'Encouragement';
    default:
      return 'Post';
  }
}

String _scheduleLabel(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekday = weekdays[value.weekday - 1];
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$weekday · $hour:$minute $period';
}