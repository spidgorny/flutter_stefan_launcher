import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/app_list_service.dart';

class AppGridSheet extends StatelessWidget {
  AppGridSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appListService = getIt<AppListService>();

    return DraggableScrollableSheet(
      builder: (context, controller) {
        return Material(
          color: theme.colorScheme.surfaceDim,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              Container(
                height: 8,
                width: 40,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          for (var app in appListService.applications)
                            FractionallySizedBox(
                              widthFactor: 0.25,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Image.memory(app.icon!),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${app.appName}",
                                      overflow: TextOverflow.ellipsis,
                                      textScaler: const TextScaler.linear(0.9),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      minChildSize: 0.5,
      initialChildSize: 0.75,
    );
  }
}
