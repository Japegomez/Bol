import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/domain/cooking_glossary_entry.dart';
import 'package:meal_planner/features/recipes/presentation/cooking_glossary_provider.dart';

class CookingGlossaryScreen extends ConsumerStatefulWidget {
  const CookingGlossaryScreen({super.key});

  @override
  ConsumerState<CookingGlossaryScreen> createState() =>
      _CookingGlossaryScreenState();
}

class _CookingGlossaryScreenState extends ConsumerState<CookingGlossaryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddEntryDialog() async {
    final termController = TextEditingController();
    final definitionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva entrada'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: termController,
                  decoration: const InputDecoration(
                    labelText: 'Término',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce un término';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: definitionController,
                  decoration: const InputDecoration(
                    labelText: 'Definición',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce una definición';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    try {
      await ref.read(cookingGlossaryProvider.notifier).addEntry(
            term: termController.text,
            definition: definitionController.text,
          );
    } on StateError catch (error) {
      if (!mounted || error.message != 'duplicate_term') rethrow;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese término ya existe en el glosario')),
      );
    }
  }

  List<CookingGlossaryEntry> _filterEntries(List<CookingGlossaryEntry> entries) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return entries;

    return entries
        .where(
          (entry) =>
              entry.term.toLowerCase().contains(query) ||
              entry.definition.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final glossaryAsync = ref.watch(cookingGlossaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Glosario culinario')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        tooltip: 'Añadir término',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar término o definición',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
              trailing: _searchController.text.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                    ]
                  : null,
            ),
          ),
          Expanded(
            child: glossaryAsync.when(
              data: (entries) {
                final filtered = _filterEntries(entries);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No hay entradas en el glosario'
                          : 'No se encontraron términos',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(entry.term),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(entry.definition),
                        ),
                        isThreeLine: true,
                        trailing: entry.isCustom
                            ? IconButton(
                                tooltip: 'Eliminar entrada',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Eliminar entrada'),
                                      content: Text(
                                        '¿Quieres eliminar "${entry.term}" del glosario?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && entry.id != null) {
                                    await ref
                                        .read(cookingGlossaryProvider.notifier)
                                        .removeCustomEntry(entry.id!);
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
