import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/entities/feedback_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/presentation/providers/feedback_provider.dart';

/// Marketing feedback screen shown after order completion.
/// Collects experience rating + "how did you hear about us" + optional comments.
class MarketingFeedbackScreen extends ConsumerStatefulWidget {
  final String orderNumber;
  final String? feedbackToken;

  const MarketingFeedbackScreen({
    super.key,
    required this.orderNumber,
    this.feedbackToken,
  });

  @override
  ConsumerState<MarketingFeedbackScreen> createState() =>
      _MarketingFeedbackScreenState();
}

class _MarketingFeedbackScreenState
    extends ConsumerState<MarketingFeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _commentsController = TextEditingController();
  final _otherSourceController = TextEditingController();
  String? _selectedRating;
  String? _selectedSource;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  static const _ratings = [
    {
      'value': 'excellent',
      'label': 'Excellent',
      'emoji': '🤩',
      'color': 0xFF4CAF50,
    },
    {'value': 'good', 'label': 'Good', 'emoji': '😊', 'color': 0xFF2196F3},
    {'value': 'fair', 'label': 'Fair', 'emoji': '😐', 'color': 0xFFFF9800},
    {'value': 'poor', 'label': 'Poor', 'emoji': '😞', 'color': 0xFFF44336},
  ];

  static const _sources = [
    {
      'value': 'google_adverts',
      'label': 'Google Adverts',
      'icon': Icons.search,
    },
    {
      'value': 'facebook_adverts',
      'label': 'Facebook Adverts',
      'icon': Icons.facebook,
    },
    {
      'value': 'instagram_promotion',
      'label': 'Instagram Promotion',
      'icon': Icons.camera_alt,
    },
    {
      'value': 'comic_awards',
      'label': 'Comic Awards',
      'icon': Icons.emoji_events,
    },
    {
      'value': 'dare_remachinda',
      'label': 'Dare Remachinda',
      'icon': Icons.person,
    },
    {'value': 'zimcelebs', 'label': 'ZimCelebs', 'icon': Icons.star},
    {
      'value': 'tiktok_advert',
      'label': 'TikTok Advert',
      'icon': Icons.play_circle,
    },
    {
      'value': 'refered_by_friend',
      'label': 'Referred by a Friend',
      'icon': Icons.people,
    },
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _otherSourceController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _selectedRating != null && _selectedSource != null;

  void _submit() async {
    if (!_canSubmit) return;

    final request = FeedbackRequest(
      orderNumber: widget.orderNumber,
      orderingProcessRating: _selectedRating!,
      heardAboutSource:
          _sources.firstWhere((s) => s['value'] == _selectedSource)['label']
              as String,
      heardAboutOther:
          _selectedSource == 'other'
              ? _otherSourceController.text.trim()
              : null,
      additionalComments:
          _commentsController.text.trim().isNotEmpty
              ? _commentsController.text.trim()
              : null,
      feedbackToken: widget.feedbackToken,
    );

    final success = await ref
        .read(feedbackNotifierProvider.notifier)
        .submitFeedback(request);

    if (success && mounted) {
      // Show the thank-you state — the build method handles it
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final state = ref.watch(feedbackNotifierProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        title: const Text(
          'Your Feedback',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/orders'),
            child: Text(
              'Skip',
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          state.isSubmitted
              ? _buildThankYou(colors, theme)
              : FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFFFF6B6B,
                                    ).withValues(alpha: 0.1),
                                    const Color(
                                      0xFFFF8E53,
                                    ).withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.rate_review_outlined,
                                size: 40,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'How was your experience?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Order #${widget.orderNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your feedback helps us improve!',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Rating section
                      _buildSectionLabel(
                        'Rate your ordering experience',
                        colors,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children:
                            _ratings.map((r) {
                              final isSelected = _selectedRating == r['value'];
                              return Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () =>
                                            _selectedRating =
                                                r['value'] as String,
                                      ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Color(
                                                r['color'] as int,
                                              ).withValues(alpha: 0.12)
                                              : colors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Color(r['color'] as int)
                                                : colors.outline.withValues(
                                                  alpha: 0.1,
                                                ),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          r['emoji'] as String,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          r['label'] as String,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? Color(r['color'] as int)
                                                    : colors.onSurface
                                                        .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // Source section
                      _buildSectionLabel('How did you hear about us?', colors),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _sources.map((s) {
                              final isSelected = _selectedSource == s['value'];
                              return GestureDetector(
                                onTap:
                                    () => setState(
                                      () =>
                                          _selectedSource =
                                              s['value'] as String,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? const Color(
                                              0xFFFF6B6B,
                                            ).withValues(alpha: 0.1)
                                            : colors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFFFF6B6B)
                                              : colors.outline.withValues(
                                                alpha: 0.1,
                                              ),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        s['icon'] as IconData,
                                        size: 16,
                                        color:
                                            isSelected
                                                ? const Color(0xFFFF6B6B)
                                                : colors.onSurface.withValues(
                                                  alpha: 0.5,
                                                ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        s['label'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? const Color(0xFFFF6B6B)
                                                  : colors.onSurface.withValues(
                                                    alpha: 0.7,
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      // "Other" text field
                      if (_selectedSource == 'other') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otherSourceController,
                          decoration: InputDecoration(
                            hintText: 'Please specify...',
                            hintStyle: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.3),
                            ),
                            filled: true,
                            fillColor: colors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Comments section
                      _buildSectionLabel(
                        'Additional comments (optional)',
                        colors,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tell us more about your experience...',
                          hintStyle: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.3),
                          ),
                          filled: true,
                          fillColor: colors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        style: TextStyle(fontSize: 14, color: colors.onSurface),
                      ),
                      const SizedBox(height: 32),

                      // Error
                      if (state.error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            state.error!,
                            style: TextStyle(color: colors.error, fontSize: 13),
                          ),
                        ),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              (_canSubmit && !state.isLoading) ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: colors.onSurface
                                .withValues(alpha: 0.1),
                            disabledForegroundColor: colors.onSurface
                                .withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child:
                              state.isLoading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Submit Feedback',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionLabel(String text, ColorScheme colors) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
    );
  }

  Widget _buildThankYou(ColorScheme colors, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    const Color(0xFF81C784).withValues(alpha: 0.12),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback has been submitted.\nWe really appreciate your time!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View My Orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
