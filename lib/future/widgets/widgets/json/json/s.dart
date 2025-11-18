// import 'package:flutter/material.dart';
// import 'package:stealth_stash/future/future.dart';
// import 'package:stealth_stash/future/state_managment/state_managment.dart';

// class JsonView extends StatefulWidget {
//   final Object text;
//   final String title;
//   const JsonView({required this.text, required this.title, super.key});

//   @override
//   State<JsonView> createState() => _JsonView();
// }

// class _JsonView extends State<JsonView> with SafeState {
//   bool selectable = false;
//   void toggeSelectable() {
//     selectable = !selectable;
//     updateState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       shrinkWrap: true,
//       slivers: [
//         SliverAppBar(
//           pinned: true,
//           title: Text(widget.title),
//           actions: [
//             IconButton(
//                 onPressed: toggeSelectable, icon: Icon(Icons.select_all)),
//           ],
//         ),
//         const SliverPadding(padding: WidgetConstant.paddingVertical10),
//         SliverPadding(
//           padding: WidgetConstant.paddingHorizontal20,
//           sliver: SliverToBoxAdapter(
//             child: Builder(
//               builder: (context) {
//                 return RichText(
//                   text: JsonNode(
//                     data: widget.text,
//                     indent: ' ',
//                     depth: 0,
//                     theme: context.theme,
//                   ).toSpan(),
//                 );
//               },
//             ),
//           ),
//         ),
//         const SliverPadding(padding: WidgetConstant.paddingVertical20),
//       ],
//     );
//   }
// }

// class JsonNode {
//   final dynamic data;
//   final String indent;
//   final int depth;
//   final ThemeData theme;

//   JsonNode({
//     required this.data,
//     required this.indent,
//     required this.depth,
//     required this.theme,
//   });

//   InlineSpan toSpan() {
//     if (data is Map) {
//       return _collapsibleSpan(
//         open: '{',
//         close: '}',
//         children: (data as Map).entries.map((e) {
//           final keyVal = e.key;
//           final keyText = keyVal is String ? '"$keyVal"' : keyVal.toString();

//           return TextSpan(
//             children: [
//               TextSpan(
//                 text: '${indent * (depth + 1)}$keyText',
//                 style: theme.textTheme.bodyMedium!,
//               ),
//               TextSpan(
//                 text: ': ',
//                 style: theme.textTheme.bodyMedium!,
//               ),
//               JsonNode(
//                 data: e.value,
//                 indent: indent,
//                 depth: depth + 1,
//                 theme: theme,
//               ).toSpan()
//             ],
//           );
//         }).toList(),
//       );
//     } else if (data is List) {
//       return _collapsibleSpan(
//         open: '[',
//         close: ']',
//         children: (data as List)
//             .map((v) => JsonNode(
//                   data: v,
//                   indent: indent,
//                   depth: depth + 1,
//                   theme: theme,
//                 ).toSpan())
//             .toList(),
//       );
//     } else if (data is String) {
//       // return WidgetSpan(child: SelectableText('"$data"'));
//       return TextSpan(
//         text: '"$data"',
//         style: theme.textTheme.bodyMedium!
//             .copyWith(color: theme.colorScheme.secondary),
//       );
//     } else if (data is num) {
//       return TextSpan(
//         text: '$data',
//         style: theme.textTheme.bodyMedium!
//             .copyWith(color: theme.colorScheme.tertiary),
//       );
//     } else if (data is bool) {
//       return TextSpan(
//         text: '$data',
//         style: theme.textTheme.bodyMedium!.copyWith(
//           color: theme.colorScheme.tertiary,
//         ),
//       );
//     } else if (data == null) {
//       return TextSpan(
//         text: 'Null',
//         style: theme.textTheme.bodyMedium!
//             .copyWith(color: theme.colorScheme.outline),
//       );
//     }
//     return TextSpan(text: data.toString(), style: theme.textTheme.bodyMedium);
//   }

//   InlineSpan _collapsibleSpan(
//       {required String open,
//       required String close,
//       required List<InlineSpan> children}) {
//     return WidgetSpan(
//       alignment: PlaceholderAlignment.baseline,
//       baseline: TextBaseline.alphabetic,
//       child: CollapsibleJson(
//         open: open,
//         close: close,
//         depth: depth,
//         indent: indent,
//         children: children,
//         theme: theme,
//       ),
//     );
//   }
// }

// class CollapsibleJson extends StatefulWidget {
//   final String open;
//   final String close;
//   final int depth;
//   final String indent;
//   final List<InlineSpan> children;
//   final ThemeData theme;

//   const CollapsibleJson({
//     super.key,
//     required this.open,
//     required this.close,
//     required this.depth,
//     required this.indent,
//     required this.children,
//     required this.theme,
//   });

//   @override
//   State<CollapsibleJson> createState() => _CollapsibleJsonState();
// }

// class _CollapsibleJsonState extends State<CollapsibleJson> {
//   bool collapsed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => setState(() => collapsed = !collapsed),
//       child: RichText(
//         text: TextSpan(
//           style: context.textTheme.titleMedium,
//           children: [
//             TextSpan(
//               text: widget.open,
//               style: context.textTheme.bodyMedium!
//                   .copyWith(color: context.colors.onSurface),
//             ),
//             if (!collapsed) ...[
//               const TextSpan(text: '\n'),
//               ..._withCommas(widget.children, context),
//               TextSpan(
//                 text: '\n${widget.indent * widget.depth}${widget.close}',
//                 style: context.textTheme.bodyMedium!
//                     .copyWith(color: context.colors.error),
//               ),
//             ] else
//               TextSpan(
//                 text: '… ${widget.close}',
//                 style: context.textTheme.bodyMedium!.copyWith(
//                   color: context.colors.outline,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<InlineSpan> _withCommas(List<InlineSpan> items, BuildContext context) {
//     final result = <InlineSpan>[];
//     for (var i = 0; i < items.length; i++) {
//       result.add(items[i]);
//       if (i < items.length - 1) {
//         result.add(TextSpan(
//           text: ',',
//           style: context.textTheme.bodyMedium!
//               .copyWith(color: context.colors.onSurface),
//         ));
//       }
//       result.add(const TextSpan(text: '\n'));
//     }
//     return result;
//   }
// }
