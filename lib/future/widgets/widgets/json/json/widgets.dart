import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/widgets/widgets/json/json/interactive_json_preview/interactive_json_preview.dart';

class JsonView extends StatefulWidget {
  final Object text;
  final String title;
  final bool selectable;

  const JsonView({
    super.key,
    required this.text,
    required this.title,
    this.selectable = false,
  });

  @override
  State<JsonView> createState() => _JsonViewState();
}

class _JsonViewState extends State<JsonView> with SafeState<JsonView> {
  bool selectable = false;
  String? _asString;

  @override
  void initState() {
    super.initState();
    selectable = widget.selectable;
  }

  void toggleSelectable() {
    updateState(() => selectable = !selectable);
  }

  String asString() {
    return _asString ??=
        StringUtils.tryFromJson(widget.text, toStringEncodable: true) ??
            widget.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(shrinkWrap: true, slivers: [
      SliverAppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: toggleSelectable,
              icon: APPAnimated(
                isActive: selectable,
                onDeactive: (context) => Icon(Icons.text_fields_outlined),
                onActive: (context) => Icon(Icons.code),
              )),
          CopyTextIcon(dataToCopy: asString()),
          CloseButton(),
          WidgetConstant.width8,
        ],
      ),
      ConditionalWidget(
          enable: selectable,
          onActive: (context) => SliverPadding(
                padding: WidgetConstant.padding20,
                sliver: SliverToBoxAdapter(
                  child: SelectableText(asString()),
                ),
              ),
          onDeactive: (context) => InteractiveJsonPreview(data: widget.text))
    ]);
  }
}
