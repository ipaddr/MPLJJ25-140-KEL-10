import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

// This is a simple redirect page to the editor in "new" mode.
// You could also directly navigate to AdminContentEditorPage without this intermediate page
// depending on how you set up your routing.

class AdminAddContentPage extends StatelessWidget {
  const AdminAddContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate directly to the editor page without a contentId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Replace with your actual route for the content editor
      context.go(
        RouteNames.adminContentEditor,
      ); // Navigate to the editor page for new content
    });

    // You can return an empty Scaffold or a loading indicator if needed
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
