import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/policy_webview_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Raines Africa',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Section
                _buildHeroSection(context),

                const SizedBox(height: 32),

                // Contact Information Header
                _buildSectionHeader(
                  context,
                  'Contact Information',
                  Icons.location_on_outlined,
                ),

                const SizedBox(height: 16),

                // Contact Cards
                ..._buildContactCards(context),

                const SizedBox(height: 32),

                // Policies Header
                _buildSectionHeader(
                  context,
                  'Policies & Legal',
                  Icons.policy_outlined,
                ),

                const SizedBox(height: 16),
              ]),
            ),
          ),

          // Policies List with better spacing
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._buildPolicyCards(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.08),
            colors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Our Story',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to Raines Africa, your premier destination for high-quality goods at affordable rates in South Africa, Zimbabwe, and Zambia. Established in April 2014, Raines Africa is a South African company committed to making quality products accessible to people across the continent.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withOpacity(0.8),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Since 2014',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContactCards(BuildContext context) {
    final contacts = [
      _ContactInfo(
        location: 'Harare, Zimbabwe',
        flag: '🇿🇼',
        address:
            'Shop No. 6 Rhodesville Shops\nNo 32 Rhodesville Avenue Greendale, Harare',
        phoneNumbers: ['+263779411028', '+263717168255'],
        email: 'admin@raines.africa',
      ),
      _ContactInfo(
        location: 'Bulawayo, Zimbabwe',
        flag: '🇿🇼',
        address:
            'Shop 20. 90 on George Square\nNo 90 George Silundika Street\nBetween 9th Avenue and 8th Avenue, opposite Watering Hole',
        phoneNumbers: ['+263771614722'],
      ),
      _ContactInfo(
        location: 'Lusaka, Zambia',
        flag: '🇿🇲',
        address:
            'Niyati Plaza, Kalingalinga Area\n35235 Alick Nkhata Rd, Lusaka, Zambia',
        phoneNumbers: ['+260777265389', '+260765914363'],
      ),
      _ContactInfo(
        location: 'Mutare, Zimbabwe',
        flag: '🇿🇼',
        address:
            '1A Twin Towers Complex\n37 Robert Mugabe Rd, Mutare\nClose to Sanhanga Building',
        phoneNumbers: ['+263789700595'],
      ),
    ];

    return contacts
        .map(
          (contact) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactCard(context, contact),
          ),
        )
        .toList();
  }

  Widget _buildContactCard(BuildContext context, _ContactInfo contact) {
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
                      contact.flag,
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
                        contact.location,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contact.address,
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
            ...contact.phoneNumbers.map(
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
            if (contact.email != null)
              InkWell(
                onTap: () => _launchEmail(contact.email!),
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
                          contact.email!,
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
                onPressed: () => _openMaps(contact.address, contact.location),
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

  List<Widget> _buildPolicyCards(BuildContext context) {
    final policies = [
      _PolicyInfo(
        title: 'Shipping Policy',
        description: 'Information about shipping and delivery',
        icon: Icons.local_shipping_outlined,
        slug: 'shipping-policy',
      ),
      _PolicyInfo(
        title: 'Return Policy',
        description: 'Learn about our return and refund policy',
        icon: Icons.assignment_return_outlined,
        slug: 'return-policy',
      ),
      _PolicyInfo(
        title: 'Privacy Policy',
        description: 'How we protect and use your personal information',
        icon: Icons.privacy_tip_outlined,
        slug: 'privacy-policy',
      ),
      _PolicyInfo(
        title: 'Terms and Conditions',
        description: 'Read our terms and conditions for using our services',
        icon: Icons.description_outlined,
        slug: 'terms-and-conditions',
      ),
    ];

    return policies
        .map(
          (policy) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildPolicyCard(context, policy),
          ),
        )
        .toList();
  }

  Widget _buildPolicyCard(BuildContext context, _PolicyInfo policy) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openPolicyWebView(context, policy),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.1),
                      colors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(policy.icon, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      policy.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.onSurface.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPolicyWebView(BuildContext context, _PolicyInfo policy) {
    final Map<String, String> slugToUrl = {
      'terms-and-conditions':
          'https://raines.africa/en/pages/terms-and-conditions',
      'privacy-policy': 'https://raines.africa/en/pages/privacy-policy',
      'return-policy': 'https://raines.africa/en/pages/return-policy',
      'shipping-policy': 'https://raines.africa/en/pages/shipping-policy',
    };

    final String? url = slugToUrl[policy.slug];
    if (url == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PolicyWebViewScreen(title: policy.title, url: url),
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

  void _openMaps(String address, String location) async {
    final query = Uri.encodeComponent('$address, $location');
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactInfo {
  final String location;
  final String flag;
  final String address;
  final List<String> phoneNumbers;
  final String? email;

  _ContactInfo({
    required this.location,
    required this.flag,
    required this.address,
    required this.phoneNumbers,
    this.email,
  });
}

class _PolicyInfo {
  final String title;
  final String description;
  final IconData icon;
  final String slug;

  _PolicyInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.slug,
  });
}
