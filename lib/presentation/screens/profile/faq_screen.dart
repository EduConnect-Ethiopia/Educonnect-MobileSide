import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/search_debouncer.dart';
import '../../../data/datasources/local/faq_data.dart';
import '../../../domain/entities/faq.dart';
import '../../providers/settings_provider.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final _searchController = TextEditingController();
  final _debouncer = SearchDebouncer();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      if (!mounted) return;
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  List<FaqCategory> _filterFaq(List<FaqCategory> source, String query) {
    if (query.isEmpty) return source;
    return source
        .map((category) {
          final items = category.items
              .where(
                (item) =>
                    item.question.toLowerCase().contains(query) ||
                    item.answer.toLowerCase().contains(query),
              )
              .toList();
          return FaqCategory(name: category.name, items: items);
        })
        .where((c) => c.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider).language;
    final categories = _filterFaq(faqCategoriesForLanguage(lang), _query);

    return Scaffold(
      appBar: AppBar(title: const Text('Frequently Asked Questions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _searchController.clear,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('No matching questions found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: categories.length,
                    itemBuilder: (context, index) =>
                        _CategoryCard(category: categories[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final FaqCategory category;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
          ),
          subtitle: Text('${category.items.length} questions'),
          children: category.items
              .map((item) => _FaqItemTile(item: item))
              .toList(),
        ),
      ),
    );
  }
}

class _FaqItemTile extends StatelessWidget {
  const _FaqItemTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            item.answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSubtitle,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
