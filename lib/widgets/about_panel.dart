import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class AboutPanel extends StatelessWidget {
  const AboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVersionCard(context),
          const SizedBox(height: 16),
          _buildContactCard(context),
        ],
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version =
            snapshot.hasData ? snapshot.data!.version : l10n.get('loading');
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('currentVersion'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${l10n.get('versionNumber')}: $version'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('contactDeveloper'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(l10n.get('sendEmail')),
              subtitle: const Text('shichen437@126.com'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub'),
              subtitle: Text(l10n.get('visitProjectPage')),
              onTap:
                  () => _launchUrl('https://github.com/shichen437/FingerLike'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
