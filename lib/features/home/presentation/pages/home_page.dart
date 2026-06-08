import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAppBar: true,
      title: 'Home Page',
      body: const Center(child: Text('Home Page')),
    );
  }
}
