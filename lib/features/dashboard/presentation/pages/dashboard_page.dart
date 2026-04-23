import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(const LoadDashboardData()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: DashboardAppBar(isSmallScreen: isMobile),
      drawer: !isDesktop ? const DashboardDrawer() : null,
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 280,
              child: DashboardDrawer(),
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const DashboardContent(),
            ),
          ),
        ],
      ),
    );
  }
}