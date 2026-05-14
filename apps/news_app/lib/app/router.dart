import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/news_item.dart';
import '../features/news/presentation/pages/news_detail_page.dart';
import '../features/news/presentation/pages/news_home_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/source_config/presentation/pages/source_config_page.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const NewsHomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'detail',
          builder: (BuildContext context, GoRouterState state) {
            final NewsItemModel item = state.extra! as NewsItemModel;
            return NewsDetailPage(item: item);
          },
        ),
        GoRoute(
          path: 'sources',
          builder: (BuildContext context, GoRouterState state) {
            return const SourceConfigPage();
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
      ],
    ),
  ],
);
