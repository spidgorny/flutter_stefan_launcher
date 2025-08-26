import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/settings.dart';
import '../../services/app_list_service.dart';
import '../../swipable.dart';
import 'list_item_without_icon.dart';

class AllAppsLauncher extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AllAppsLauncher({super.key});
  @override
  State<AllAppsLauncher> createState() => _AllAppsLauncherState();
}

class _AllAppsLauncherState extends State<AllAppsLauncher> {
  var startTime = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  debugPrintX(String message) {
    debugPrint('${DateTime.now().difference(startTime)} $message');
    startTime = DateTime.now();
  }

  @override
  void initState() {
    super.initState(); // Call super.initState() first
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrintX('build');
    var appListService = watchIt<AppListService>();
    final settings = watch(di<Settings>());
    final dataRepo = watch(di<DataRepo>());

    var searchResults = appListService.applications;
    if (_searchController.text != '') {
      searchResults = searchResults
          .where(
            (app) => (app.appName ?? app.packageName).toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    Widget x = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          leading: IconButton(
            color: settings.isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              SwipeableScaffold.of(context)?.scrollBackToCenter();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 18),
              border: InputBorder.none,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {});
            },
            cursorColor: Colors.black,
          ),
          foregroundColor: Colors.blueAccent,
        ),
      ),
      body: dataRepo.isLoading || appListService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final app = searchResults[index];
                  return ListItemWithoutIcon(app);
                },
              ),
            ),
    );
    debugPrintX('build done');
    return x;
  }
}
