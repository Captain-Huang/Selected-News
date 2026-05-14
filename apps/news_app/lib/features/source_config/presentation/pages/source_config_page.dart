import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/source.dart';
import '../state/source_config_controller.dart';

class SourceConfigPage extends ConsumerWidget {
  const SourceConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SourceConfigState> state = ref.watch(
      sourceConfigControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Source Config'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref
                  .read(sourceConfigControllerProvider.notifier)
                  .refreshSources();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final _SourceFormResult? result = await _showAddSourceDialog(context);
          if (result == null || !context.mounted) {
            return;
          }
          await ref
              .read(sourceConfigControllerProvider.notifier)
              .addSource(
                name: result.name,
                baseUrl: result.baseUrl,
                type: result.type,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Source added')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Load failed: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(sourceConfigControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (SourceConfigState data) {
          return Column(
            children: <Widget>[
              _CategorySelector(
                categories: data.categories,
                selectedCategoryId: data.selectedCategoryId,
                onChanged: (int categoryId) {
                  ref
                      .read(sourceConfigControllerProvider.notifier)
                      .selectCategory(categoryId);
                },
              ),
              if (data.saving) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: _SourceList(
                  sources: data.sources,
                  onToggle: (SourceModel source, bool enabled) async {
                    await ref
                        .read(sourceConfigControllerProvider.notifier)
                        .toggleEnabled(sourceId: source.id, enabled: enabled);
                  },
                  onDelete: (SourceModel source) async {
                    final bool confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete source'),
                              content: Text('Delete "${source.name}"?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                    if (!confirmed) {
                      return;
                    }
                    await ref
                        .read(sourceConfigControllerProvider.notifier)
                        .deleteSource(source.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Source deleted')),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_SourceFormResult?> _showAddSourceDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    String selectedType = 'rss';

    return showDialog<_SourceFormResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext localContext, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add source'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'OpenAI Blog RSS',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        hintText: 'https://example.com/rss.xml',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'rss', child: Text('rss')),
                        DropdownMenuItem(value: 'api', child: Text('api')),
                        DropdownMenuItem(value: 'html', child: Text('html')),
                      ],
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => selectedType = value);
                      },
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final String name = nameController.text.trim();
                    final String baseUrl = urlController.text.trim();
                    if (name.isEmpty || baseUrl.isEmpty) {
                      ScaffoldMessenger.of(localContext).showSnackBar(
                        const SnackBar(
                          content: Text('Name and URL are required'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(
                      _SourceFormResult(
                        name: name,
                        baseUrl: baseUrl,
                        type: selectedType,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final CategoryModel category = categories[index];
          final bool selected = category.id == selectedCategoryId;
          return ChoiceChip(
            selected: selected,
            label: Text(category.name),
            onSelected: (bool selectedValue) => onChanged(category.id),
          );
        },
      ),
    );
  }
}

class _SourceList extends StatelessWidget {
  const _SourceList({
    required this.sources,
    required this.onToggle,
    required this.onDelete,
  });

  final List<SourceModel> sources;
  final Future<void> Function(SourceModel source, bool enabled) onToggle;
  final Future<void> Function(SourceModel source) onDelete;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const Center(child: Text('No source in this category'));
    }
    return ListView.separated(
      itemCount: sources.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final SourceModel source = sources[index];
        return ListTile(
          title: Text(source.name),
          subtitle: Text(
            source.baseUrl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            radius: 14,
            child: Text(
              source.type.toUpperCase(),
              style: const TextStyle(fontSize: 9),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Switch(
                value: source.enabled,
                onChanged: (bool value) => onToggle(source, value),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => onDelete(source),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SourceFormResult {
  _SourceFormResult({
    required this.name,
    required this.baseUrl,
    required this.type,
  });

  final String name;
  final String baseUrl;
  final String type;
}
