import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/entities/voucher_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/presentation/providers/voucher_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:intl/intl.dart';

class GiftCardsScreen extends ConsumerStatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  ConsumerState<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends ConsumerState<GiftCardsScreen> {
  final _codeController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isVerifying = false;
  bool _isRedeeming = false;
  VoucherActionResult? _verifyResult;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── Filter chips ──

  static const _filters = [
    {'key': 'all', 'label': 'All Cards', 'icon': Icons.card_giftcard},
    {'key': 'active', 'label': 'Active', 'icon': Icons.auto_awesome},
    {'key': 'redeemed', 'label': 'Redeemed', 'icon': Icons.check_box},
    {'key': 'expired', 'label': 'Expired', 'icon': Icons.cancel_outlined},
  ];

  List<VoucherEntity> _applyFilter(List<VoucherEntity> vouchers) {
    switch (_selectedFilter) {
      case 'active':
        return vouchers.where((v) => v.isActive).toList();
      case 'redeemed':
        return vouchers.where((v) => v.isRedeemed).toList();
      case 'expired':
        return vouchers.where((v) => v.isExpired).toList();
      default:
        return vouchers;
    }
  }

  // ── Stats ──

  Map<String, int> _computeStats(List<VoucherEntity> vouchers) {
    int active = 0, redeemed = 0;
    for (final v in vouchers) {
      if (v.isActive) active++;
      if (v.isRedeemed) redeemed++;
    }
    return {'total': vouchers.length, 'active': active, 'redeemed': redeemed};
  }

  // ── Actions ──

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnackBar('Please enter a voucher code', isError: true);
      return;
    }
    setState(() {
      _isVerifying = true;
      _verifyResult = null;
    });
    final repo = ref.read(voucherRepositoryProvider);
    final result = await repo.checkVoucher(code);
    result.fold(
      (failure) {
        _showSnackBar(failure.message, isError: true);
        setState(() => _isVerifying = false);
      },
      (actionResult) {
        setState(() {
          _isVerifying = false;
          _verifyResult = actionResult;
        });
        if (actionResult.success) {
          _showSnackBar(actionResult.message);
        } else {
          _showSnackBar(actionResult.message, isError: true);
        }
      },
    );
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnackBar('Please enter a voucher code', isError: true);
      return;
    }
    setState(() => _isRedeeming = true);
    final repo = ref.read(voucherRepositoryProvider);
    final result = await repo.redeemVoucher(code);
    setState(() => _isRedeeming = false);
    result.fold((failure) => _showSnackBar(failure.message, isError: true), (
      actionResult,
    ) {
      if (actionResult.success) {
        _showSnackBar(actionResult.message);
        _codeController.clear();
        setState(() => _verifyResult = null);
        // Refresh the voucher lists
        ref.invalidate(myVouchersProvider);
        ref.invalidate(redeemedVouchersProvider);
      } else {
        _showSnackBar(actionResult.message, isError: true);
      }
    });
  }

  Future<void> _resendEmail(int voucherId) async {
    final repo = ref.read(voucherRepositoryProvider);
    final result = await repo.resendVoucherEmail(voucherId);
    result.fold(
      (failure) => _showSnackBar(failure.message, isError: true),
      (message) => _showSnackBar(message),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vouchersAsync = ref.watch(myVouchersProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Gift Cards & Vouchers'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myVouchersProvider);
          ref.invalidate(redeemedVouchersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRedeemSection(colors, theme),
              const SizedBox(height: 24),
              _buildMyGiftCardsSection(colors, theme, vouchersAsync),
            ],
          ),
        ),
      ),
    );
  }

  // ── Redeem Section ──

  Widget _buildRedeemSection(ColorScheme colors, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with accent bar
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Redeem Gift Card',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your gift card code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                ],
                decoration: InputDecoration(
                  hintText: 'XXX-XXXX-XXXX',
                  hintStyle: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.35),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              // Verify result info
              if (_verifyResult != null && _verifyResult!.success) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voucher is valid!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                            if (_verifyResult!.voucher != null)
                              Text(
                                '${_verifyResult!.voucher!.currencyCode} ${_verifyResult!.voucher!.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Buttons row
              Row(
                children: [
                  // Verify Code
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isVerifying ? null : _verifyCode,
                      icon:
                          _isVerifying
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primary,
                                ),
                              )
                              : Icon(Icons.check, size: 18),
                      label: const Text('Verify Code'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Redeem Now
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isRedeeming ? null : _redeemCode,
                      icon:
                          _isRedeeming
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.card_giftcard, size: 18),
                      label: const Text('Redeem Now'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── My Gift Cards Section ──

  Widget _buildMyGiftCardsSection(
    ColorScheme colors,
    ThemeData theme,
    AsyncValue<List<VoucherEntity>> vouchersAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with accent bar
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'My Gift Cards',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats row
        vouchersAsync.when(
          data: (vouchers) {
            final stats = _computeStats(vouchers);
            return Column(
              children: [
                _buildStatsRow(colors, theme, stats),
                const SizedBox(height: 16),
                _buildFilterChips(colors, theme, vouchers.length),
                const SizedBox(height: 16),
                _buildVoucherList(colors, theme, _applyFilter(vouchers)),
              ],
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
          error: (error, _) => _buildErrorState(colors, theme, error),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    ColorScheme colors,
    ThemeData theme,
    Map<String, int> stats,
  ) {
    return Row(
      children: [
        _buildStatCard(
          colors,
          theme,
          stats['total'] ?? 0,
          'TOTAL CARDS',
          colors.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          colors,
          theme,
          stats['active'] ?? 0,
          'ACTIVE',
          Colors.green.shade600,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          colors,
          theme,
          stats['redeemed'] ?? 0,
          'REDEEMED',
          colors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme colors,
    ThemeData theme,
    int value,
    String label,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    ColorScheme colors,
    ThemeData theme,
    int totalCount,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _filters.map((f) {
              final key = f['key'] as String;
              final label = f['label'] as String;
              final icon = f['icon'] as IconData;
              final isSelected = _selectedFilter == key;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = key),
                  avatar: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : colors.onSurface,
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label),
                      if (isSelected && key == 'all') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalCount.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  selectedColor: colors.primary,
                  backgroundColor: colors.surface,
                  side: BorderSide(
                    color:
                        isSelected
                            ? colors.primary
                            : colors.outline.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildVoucherList(
    ColorScheme colors,
    ThemeData theme,
    List<VoucherEntity> vouchers,
  ) {
    if (vouchers.isEmpty) {
      return _buildEmptyState(colors, theme);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildVoucherCard(vouchers[index], colors, theme);
      },
    );
  }

  Widget _buildVoucherCard(
    VoucherEntity voucher,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final formatCurrency = ref.watch(currencyFormattingProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (voucher.status) {
      case 'redeemed':
        statusColor = Colors.blue.shade600;
        statusIcon = Icons.check_circle;
        statusLabel = 'Redeemed';
        break;
      case 'expired':
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
        statusLabel = 'Expired';
        break;
      default:
        statusColor = Colors.green.shade600;
        statusIcon = Icons.auto_awesome;
        statusLabel = 'Active';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — amount + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(voucher.amount),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 16,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    voucher.code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: colors.onSurface.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: voucher.code));
                    _showSnackBar('Code copied to clipboard');
                  },
                  child: Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Product name
          if (voucher.product != null)
            Text(
              voucher.product!.name,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          // Dates
          const SizedBox(height: 8),
          Row(
            children: [
              if (voucher.createdAt != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 13,
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  'Purchased: ${dateFormat.format(voucher.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const Spacer(),
              if (voucher.expiresAt != null)
                Text(
                  'Expires: ${dateFormat.format(voucher.expiresAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        voucher.isExpired
                            ? Colors.red.shade400
                            : colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          // Action buttons
          if (voucher.isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resendEmail(voucher.id),
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: const Text('Resend Email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.shareVoucher(context, voucher.code, voucher.amount);
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (voucher.isRedeemed && voucher.redeemedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Redeemed on: ${dateFormat.format(voucher.redeemedAt!)}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.blue.shade400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 48,
                color: colors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Gift Cards Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t purchased any gift cards yet.\nGift cards make perfect gifts!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colors, ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load gift cards',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(myVouchersProvider);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple share helper — we avoid the share_plus dependency
// and just use clipboard + snack for now.
class Share {
  static void shareVoucher(BuildContext context, String code, double amount) {
    final text =
        'Here\'s a Raines Africa gift card for \$${amount.toStringAsFixed(2)}! '
        'Redeem it with code: $code';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gift card details copied — share it anywhere!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
