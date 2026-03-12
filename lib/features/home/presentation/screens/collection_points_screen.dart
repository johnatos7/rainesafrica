import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Data class for a collection point
class _CollectionPoint {
  final String location;
  final String flag;
  final String address;
  final List<String> phoneNumbers;
  final String? email;
  final String directionsUrl;

  _CollectionPoint({
    required this.location,
    required this.flag,
    required this.address,
    required this.phoneNumbers,
    required this.directionsUrl,
    this.email,
  });
}

class CollectionPointsScreen extends StatelessWidget {
  const CollectionPointsScreen({super.key});

  static final List<_CollectionPoint> _collectionPoints = [
    _CollectionPoint(
      location: 'Harare, Zimbabwe',
      flag: '🇿🇼',
      address:
          'Shop No. 6 Rhodesville Shops\nNo 32 Rhodesville Avenue Greendale, Harare',
      phoneNumbers: ['+263779411028', '+263717168255'],
      email: 'admin@raines.africa',
      directionsUrl: 'https://maps.app.goo.gl/EWGGRPPtBrs7t3Ym6?g_st=aw',
    ),
    _CollectionPoint(
      location: 'Bulawayo, Zimbabwe',
      flag: '🇿🇼',
      address:
          'Shop 20. 90 on George Square\nNo 90 George Silundika Street\nBetween 9th Avenue and 8th Avenue, opposite Watering Hole',
      phoneNumbers: ['+263771614722'],
      directionsUrl: 'https://maps.app.goo.gl/ibyq35i3fZewFx5X8?g_st=aw',
    ),
    _CollectionPoint(
      location: 'Lusaka, Zambia',
      flag: '🇿🇲',
      address:
          'Niyati Plaza, Kalingalinga Area\n35235 Alick Nkhata Rd, Lusaka, Zambia',
      phoneNumbers: ['+260777265389', '+260765914363'],
      directionsUrl: 'https://maps.app.goo.gl/FtsiGjHU4U7Jc1ir7?g_st=aw',
    ),
    _CollectionPoint(
      location: 'Mutare, Zimbabwe',
      flag: '🇿🇼',
      address:
          '1A Twin Towers Complex\n37 Robert Mugabe Rd, Mutare\nClose to Sanhanga Building',
      phoneNumbers: ['+263789700595'],
      directionsUrl: 'https://maps.app.goo.gl/raahFjYny63gvZ226?g_st=aw',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Collection Points',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withOpacity(0.08),
                  colors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.store_outlined,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick up your orders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visit any of our collection points to collect your orders',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Collection point cards
          ..._collectionPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCollectionPointCard(context, point),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPointCard(
    BuildContext context,
    _CollectionPoint point,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      point.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.location,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone numbers — tappable
            ...point.phoneNumbers.map(
              (phone) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _launchPhone(phone),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: colors.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            phone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.call_outlined,
                          size: 16,
                          color: colors.primary.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Email — tappable
            if (point.email != null)
              InkWell(
                onTap: () => _launchEmail(point.email!),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: colors.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: colors.primary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),
            // Directions button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openMaps(point.directionsUrl),
                icon: const Icon(Icons.directions_outlined, size: 18),
                label: const Text('Get Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMaps(String directionsUrl) async {
    final uri = Uri.parse(directionsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
