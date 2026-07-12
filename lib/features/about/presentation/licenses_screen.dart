import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_values.dart';
import '../../../shared/widgets/health_card.dart';

/// Programmatic representation of grouped license information
class _PackageLicense {
  final String packageName;
  final List<LicenseEntry> entries;

  _PackageLicense({
    required this.packageName,
    required this.entries,
  });
}

/// Custom Premium Licenses Screen listing third-party open source packages
class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  final List<_PackageLicense> _packages = [];
  List<_PackageLicense> _filteredPackages = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLicenses() async {
    try {
      final List<LicenseEntry> rawLicenses = await LicenseRegistry.licenses.toList();
      
      // Group license entries by package name
      final Map<String, List<LicenseEntry>> grouped = {};
      for (final entry in rawLicenses) {
        for (final package in entry.packages) {
          grouped.putIfAbsent(package, () => []).add(entry);
        }
      }

      final List<_PackageLicense> list = grouped.entries.map((e) {
        return _PackageLicense(packageName: e.key, entries: e.value);
      }).toList();

      // Sort alphabetically by package name
      list.sort((a, b) => a.packageName.toLowerCase().compareTo(b.packageName.toLowerCase()));

      if (mounted) {
        setState(() {
          _packages.addAll(list);
          _filteredPackages = List.from(_packages);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterLicenses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPackages = List.from(_packages);
      } else {
        _filteredPackages = _packages
            .where((p) => p.packageName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Source Licenses'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading licenses...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── SEARCH BAR ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterLicenses,
                      decoration: InputDecoration(
                        hintText: 'Search packages...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterLicenses('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                          vertical: AppSpacing.m,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── PACKAGE LIST ──
                Expanded(
                  child: _filteredPackages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No packages found matching "$_searchQuery"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredPackages.length,
                          itemBuilder: (context, index) {
                            final package = _filteredPackages[index];
                            final count = package.entries.length;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: HealthCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.l,
                                    vertical: AppSpacing.xs,
                                  ),
                                  title: Text(
                                    package.packageName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$count ${count == 1 ? 'license' : 'licenses'}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LicenseDetailScreen(
                                          packageName: package.packageName,
                                          entries: package.entries,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// Custom Premium License Details Screen displaying the full text of licenses
class LicenseDetailScreen extends StatelessWidget {
  final String packageName;
  final List<LicenseEntry> entries;

  const LicenseDetailScreen({
    super.key,
    required this.packageName,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(packageName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy all licenses',
            onPressed: () {
              final text = entries.map((entry) {
                return entry.paragraphs.map((p) => p.text).join('\n\n');
              }).join('\n\n---\n\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Licenses copied to clipboard! 📋'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final text = entry.paragraphs.map((p) => p.text).join('\n\n');

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: HealthCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entries.length > 1) ...[
                    Text(
                      'License #${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SelectableText(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
