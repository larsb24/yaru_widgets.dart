import 'dart:math';

import 'package:flutter/material.dart';

import 'yaru_navigation_page_theme.dart';
import 'yaru_navigation_rail.dart';
import 'yaru_page_controller.dart';

typedef YaruNavigationPageBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

const _kScrollbarThickness = 4.0;

/// A page layout which use a [YaruNavigationRail] on left for page navigation
class YaruNavigationPage extends StatefulWidget {
  const YaruNavigationPage({
    super.key,
    this.length,
    required this.itemBuilder,
    required this.pageBuilder,
    this.initialIndex,
    this.onSelected,
    this.controller,
    this.leading,
    this.trailing,
  })  : assert(initialIndex == null || controller == null),
        assert((length == null) != (controller == null));

  /// The total number of pages.
  final int? length;

  /// A builder that is called for each page to build its navigation rail item.
  ///
  /// See also:
  ///  * [YaruNavigationRailItem]
  final YaruNavigationPageBuilder itemBuilder;

  /// A builder that is called for each page to build its content.
  final IndexedWidgetBuilder pageBuilder;

  /// The index of the initial page to show.
  final int? initialIndex;

  /// Called when the user selects a page.
  final ValueChanged<int>? onSelected;

  /// An optional controller that can be used to navigate to a specific index.
  final YaruPageController? controller;

  /// The leading widget in the rail that is placed above the destinations.
  final Widget? leading;

  /// The trailing widget in the rail that is placed below the destinations.
  final Widget? trailing;

  @override
  State<YaruNavigationPage> createState() => _YaruNavigationPageState();
}

class _YaruNavigationPageState extends State<YaruNavigationPage> {
  late final ScrollController _scrollController;
  late final YaruPageController _pageController;

  int get _length => widget.length ?? widget.controller!.length;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updatePageController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.removeListener(_pageControllerCallback);
    if (widget.controller == null) _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant YaruNavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_pageControllerCallback);
      _updatePageController();
    }
  }

  void _updatePageController() {
    _pageController =
        widget.controller ?? YaruPageController(length: widget.length!);
    _pageController.addListener(_pageControllerCallback);
  }

  void _pageControllerCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SafeArea(
          child: Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavigationRail(context, constraint),
                _buildVerticalSeparator(),
                _buildPageView(context),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTap(int index) {
    _pageController.index = index;
    widget.onSelected?.call(index);
  }

  Widget _buildNavigationRail(BuildContext context, BoxConstraints constraint) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarTheme.of(context).copyWith(
          thickness: MaterialStateProperty.all(_kScrollbarThickness),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: YaruNavigationRail(
            selectedIndex: max(_pageController.index, 0),
            onDestinationSelected: _onTap,
            length: _length,
            itemBuilder: widget.itemBuilder,
            leading: widget.leading,
            trailing: widget.trailing,
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSeparator() {
    return const VerticalDivider(thickness: 1, width: 1);
  }

  Widget _buildPageView(BuildContext context) {
    final theme = YaruCompactLayoutTheme.of(context);
    final index = max(_pageController.index, 0);

    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          pageTransitionsTheme: theme.pageTransitions,
        ),
        child: Navigator(
          pages: [
            MaterialPage(
              key: ValueKey(index),
              child: _length > index
                  ? widget.pageBuilder(context, index)
                  : widget.pageBuilder(context, 0),
            ),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ),
    );
  }
}
