import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import '../constants.dart';

/// A generic wrapper around [PopupMenuButton] that is visually more consistent
/// to buttons and dialogs than [DropdownButton]
class YaruPopupMenuButton<T> extends StatelessWidget {
  const YaruPopupMenuButton({
    super.key,
    required this.initialValue,
    required this.child,
    required this.itemBuilder,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.position = PopupMenuPosition.under,
    this.padding = const EdgeInsets.symmetric(horizontal: 5),
    this.childPadding = const EdgeInsets.symmetric(horizontal: 5),
    this.enabled = true,
  });

  final T initialValue;
  final Widget child;
  final Function(T)? onSelected;
  final Function()? onCanceled;
  final String? tooltip;
  final PopupMenuPosition position;
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;
  final EdgeInsets padding;
  final EdgeInsets childPadding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kYaruButtonRadius),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          enabled: enabled,
          position: position,
          padding: EdgeInsets.zero,
          initialValue: initialValue,
          onSelected: onSelected,
          onCanceled: onCanceled,
          tooltip: tooltip,
          itemBuilder: itemBuilder,
          child: _YaruPopupDecoration(
            child: child,
            padding: padding,
            childPadding: childPadding,
          ),
        ),
      ),
    );
  }
}

class _YaruPopupDecoration extends StatelessWidget {
  const _YaruPopupDecoration({
    // ignore: unused_element
    super.key,
    required this.child,
    required this.padding,
    required this.childPadding,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets childPadding;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      child: Container(
        padding: childPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kYaruButtonRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: padding,
              child: child,
            ),
            const SizedBox(
              height: 40,
              child: Icon(
                YaruIcons.pan_down,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YaruMultiSelectItem<T> extends StatefulWidget {
  const YaruMultiSelectItem({
    super.key,
    required this.values,
    required this.value,
    this.contentPadding = const EdgeInsets.only(right: 2, left: 10),
    required this.child,
    required this.onTap,
  });

  final Set<T> values;
  final void Function() onTap;
  final T value;
  final Widget child;
  final EdgeInsets contentPadding;

  @override
  State<YaruMultiSelectItem> createState() => _YaruMultiSelectItemState();
}

class _YaruMultiSelectItemState extends State<YaruMultiSelectItem> {
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      contentPadding: widget.contentPadding,
      onTap: () {
        setState(() {
          widget.onTap();
        });
      },
      leading: widget.values.contains(widget.value)
          ? Icon(
              YaruIcons.checkbox_button_checked,
              color: iconColor,
            )
          : Icon(
              YaruIcons.checkbox_button,
              color: iconColor,
            ),
      title: widget.child,
    );
  }
}
