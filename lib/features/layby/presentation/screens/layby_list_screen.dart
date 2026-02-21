import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_card_widget.dart';

/// Screen showing user's layby applications with status filter tabs
class LaybyListScreen extends ConsumerStatefulWidget {
  const LaybyListScreen({super.key});

  @override
  ConsumerState<LaybyListScreen> createState() => _LaybyListScreenState();
}

class _LaybyListScreenState extends ConsumerState<LaybyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Active',
    'Completed',
    'Rejected',
    'Cancelled',
  ];

  String? get _currentStatus {
    final idx = _tabController.index;
    return idx == 0 ? null : _statusFilters[idx].toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Triggers rebuild to fetch with new status
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final applicationsAsync = ref.watch(
      laybyApplicationsProvider(ApplicationsListParams(status: _currentStatus)),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'My Laybys',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.5),
          indicatorColor: colors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: _statusFilters.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: applicationsAsync.when(
        data: (response) {
          // The API may not filter by status server-side, so apply
          // client-side filtering when a specific tab is selected.
          final filtered =
              _currentStatus == null
                  ? response.data
                  : response.data
                      .where(
                        (app) => app.status.toLowerCase() == _currentStatus,
                      )
                      .toList();

          if (filtered.isEmpty) {
            return _buildEmptyState(colors);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                laybyApplicationsProvider(
                  ApplicationsListParams(status: _currentStatus),
                ),
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final app = filtered[index];
                return LaybyCardWidget(
                  application: app,
                  onTap: () => context.push('/layby/${app.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(
                          laybyApplicationsProvider(
                            ApplicationsListParams(status: _currentStatus),
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: colors.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No Layby Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse products and apply for layby\nto pay in easy installments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
