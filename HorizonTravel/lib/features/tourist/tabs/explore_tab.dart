import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'guides_tab.dart';
import 'slots_tab.dart';

class ExploreTab extends StatefulWidget {
  final int initialSubTab;
  final String? initialCategory;
  final String? initialQuery;

  const ExploreTab({
    super.key,
    this.initialSubTab = 0,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<ExploreTab> createState() => ExploreTabState();
}

class ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<SlotsTabState> _slotsKey = GlobalKey<SlotsTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSubTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void selectSubTab(int index) {
    if (index >= 0 && index < 2) {
      _tabController.animateTo(index);
    }
  }

  void filterCategory(String category) {
    _tabController.animateTo(0);
    _slotsKey.currentState?.setFilterCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.travel_explore_rounded),
                text: 'Services & Spots',
              ),
              Tab(
                icon: Icon(Icons.person_pin_circle_rounded),
                text: 'Tour Guides',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SlotsTab(
                key: _slotsKey,
                initialCategory: widget.initialCategory,
                initialQuery: widget.initialQuery,
              ),
              const GuidesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
