import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/news_item.dart';
import '../state/news_tab_controller.dart';
import '../widgets/news_card.dart';

class NewsHomePage extends ConsumerWidget {
  const NewsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<String>> categoriesAsync = ref.watch(
      categoriesProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected News'),
        actions: <Widget>[
          IconButton(
            tooltip: '来源配置',
            onPressed: () => context.push('/sources'),
            icon: const Icon(Icons.link),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (List<String> categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('暂无分类'));
          }
          return DefaultTabController(
            length: categories.length,
            child: Column(
              children: <Widget>[
                TabBar(
                  isScrollable: true,
                  tabs: categories
                      .map((String category) => Tab(text: category))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories
                        .map(
                          (String category) => _NewsTabView(category: category),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
        error: (Object error, StackTrace stack) =>
            Center(child: Text('分类加载失败: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _NewsTabView extends ConsumerStatefulWidget {
  const _NewsTabView({required this.category});

  final String category;

  @override
  ConsumerState<_NewsTabView> createState() => _NewsTabViewState();
}

class _NewsTabViewState extends ConsumerState<_NewsTabView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final double threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(newsTabControllerProvider(widget.category).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NewsTabState> state = ref.watch(
      newsTabControllerProvider(widget.category),
    );

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('加载失败: $error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref
                  .read(newsTabControllerProvider(widget.category).notifier)
                  .refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (NewsTabState data) {
        if (data.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref
                .read(newsTabControllerProvider(widget.category).notifier)
                .refresh(),
            child: ListView(
              children: const <Widget>[
                SizedBox(height: 160),
                Center(child: Text('暂无新闻')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref
              .read(newsTabControllerProvider(widget.category).notifier)
              .refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount:
                data.items.length +
                (data.hasMore || data.isLoadingMore ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index >= data.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final NewsItemModel item = data.items[index];
              return NewsCard(
                item: item,
                onTap: () => context.push('/detail', extra: item),
              );
            },
          ),
        );
      },
    );
  }
}
