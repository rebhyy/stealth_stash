// MIT License
// Copyright (c) 2024 Yeikel Uriarte Arteaga
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';

class InteractiveJsonPreview extends StatefulWidget {
  /// {@macro interactive_json_preview}
  const InteractiveJsonPreview(
      {required this.data, super.key, this.indentLength = 4});

  /// JSON String
  final dynamic data;

  /// Indent length in spaces, default to 4
  final int indentLength;

  @override
  InteractiveJsonPreviewState createState() => InteractiveJsonPreviewState();
}

// ignore: public_member_api_docs
class InteractiveJsonPreviewState extends State<InteractiveJsonPreview> {
  final Map<String, bool> _expandedState = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final childrens = _buildChildren(widget.data);
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList.builder(
        itemCount: childrens.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '${index + 1}: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: childrens[index],
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildJsonMapView(
    Map<String, dynamic> jsonData,
    String parentKey,
    int depth,
  ) {
    final jsonView = <Widget>[];

    if (depth == 0) {
      jsonView.add(
        SelectableText('{', style: bodySmall),
      );
    }

    for (final entrie in jsonData.entries.indexed) {
      final (String key, dynamic value) = (entrie.$2.key, entrie.$2.value);
      final index = entrie.$1;
      final nodeKey = parentKey.isEmpty ? key : '$parentKey.$key.$index';
      final isExpanded = _expandedState[nodeKey] ?? true;

      final isMap = value is Map;
      final isList = value is List;

      final valueLegth = _getLegthofValue(value);

      final leftPadding = depth * widget.indentLength.toDouble();
      jsonView.add(
        Padding(
          padding: EdgeInsets.only(left: max(leftPadding, 6)),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _expandedState[nodeKey] = !isExpanded;
              });
            },
            child: Row(
              children: [
                if (isMap || isList)
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more,
                    size: 16,
                    color: Colors.grey,
                  ),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(
                      text: '"$key": ',
                      style: bodySmall,
                      children: [
                        if (isExpanded && isMap)
                          TextSpan(
                            text: ' {',
                            style: bodySmall,
                          ),
                        if (isExpanded && isList)
                          TextSpan(
                            text: ' [',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (!isExpanded && (isMap || isList)) ...[
                          TextSpan(
                            text: isMap ? '{...}' : '[...]',
                            style: bodySmall,
                          ),
                          TextSpan(
                            text: ' // $valueLegth items',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (!isList && !isMap)
                          TextSpan(
                            text: _formatValue(value),
                            style: _getValueTextStyle(value),
                            children: [
                              TextSpan(
                                text: ',',
                                style: bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (isExpanded) {
        if (isMap) {
          jsonView
            ..addAll(
              _buildJsonMapView(value.map((k, v) => MapEntry(k.toString(), v)),
                  nodeKey, depth + 1),
            )
            ..add(
              Padding(
                padding: EdgeInsets.only(
                  left: depth * widget.indentLength.toDouble(),
                ),
                child: SelectableText(' },', style: bodySmall),
              ),
            );
        } else if (isList) {
          jsonView
            ..addAll(
              _buildJsonObjectListView(
                value,
                nodeKey,
                depth + 1,
              ),
            )
            ..add(
              Padding(
                padding: EdgeInsets.only(
                  left: depth * widget.indentLength.toDouble(),
                ),
                child: SelectableText(' ],', style: bodySmall),
              ),
            );
        }
      }
    }

    if (depth == 0) {
      jsonView.add(
        SelectableText('}', style: bodySmall),
      );
    }

    return jsonView;
  }

  List<Widget> _buildJsonObjectListView(
    List<dynamic> jsonData,
    String parentKey,
    int depth,
  ) {
    final jsonObjectView = <Widget>[];

    if (depth == 0) {
      jsonObjectView.add(
        SelectableText('[', style: bodySmall),
      );
    }

    for (final (index, value) in jsonData.indexed) {
      final stateKey = '$parentKey.$index';
      final isMap = value is Map;
      final isList = value is List;
      final isExpanded = _expandedState[stateKey] ?? true;

      final valueLegth = _getLegthofValue(value);

      jsonObjectView.add(
        Padding(
          padding:
              EdgeInsets.only(left: depth * widget.indentLength.toDouble()),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _expandedState[stateKey] = !isExpanded;
              });
            },
            child: Row(
              children: [
                if (isMap || isList)
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16, color: Colors.grey),
                if (!isExpanded && (isMap || isList))
                  Text.rich(
                    TextSpan(
                      text: isMap ? '{...}' : '[...]',
                      style: bodySmall,
                      children: [
                        TextSpan(
                            text: ' // $valueLegth items',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  ),
                if (!isList && !isMap)
                  Expanded(
                    child: SelectableText.rich(
                      TextSpan(
                        text: _formatValue(value),
                        style: _getValueTextStyle(value),
                        children: [
                          TextSpan(text: ',', style: bodySmall),
                        ],
                      ),
                      maxLines: 1,
                    ),
                  )
                else if (isExpanded)
                  SelectableText(' {', style: bodySmall),
              ],
            ),
          ),
        ),
      );

      if (isExpanded) {
        if (isMap) {
          jsonObjectView
            ..addAll(
              _buildJsonMapView(value.map((k, v) => MapEntry(k.toString(), v)),
                  stateKey, depth + 1),
            )
            ..add(
              Padding(
                padding: EdgeInsets.only(
                    left: depth * widget.indentLength.toDouble()),
                child: SelectableText(' },', style: bodySmall),
              ),
            );
        } else if (isList) {
          for (var i = 0; i < value.length; i++) {
            final item = value[i];
            if (item is Map) {
              jsonObjectView.addAll(
                _buildJsonMapView(item.map((k, v) => MapEntry(k.toString(), v)),
                    '$stateKey.$i', depth + 1),
              );
            } else {
              jsonObjectView.addAll(
                _buildJsonObjectListView(
                    item is List ? item : [item], '$stateKey.$i', depth + 1),
              );
            }
          }
          jsonObjectView.add(
            Padding(
                padding: EdgeInsets.only(
                  left: depth * widget.indentLength.toDouble(),
                ),
                child: SelectableText(' ]', style: bodySmall)),
          );
        }
      }
    }

    if (depth == 0) {
      jsonObjectView.add(SelectableText(']', style: bodySmall));
    }
    return jsonObjectView;
  }

  int _getLegthofValue(dynamic value) {
    final valueLegth = switch (value) {
      final Map<String, dynamic> map => map.length,
      final List<dynamic> list => list.length,
      _ => 0,
    };
    return valueLegth;
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return '"$value"';
    }
    if (value == null) {
      return 'null';
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    return value.toString();
  }

  /// Current text theme
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Current small body text theme
  TextStyle? get bodySmall =>
      textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis);

  TextStyle? _getValueTextStyle(dynamic value) {
    if (value is String) {
      return bodySmall;
    }
    if (value == null) {
      return bodySmall;
    }
    if (value is int) {
      return bodySmall;
    }
    if (value is bool) {
      return bodySmall;
    }
    if (value is double) {
      return bodySmall;
    }
    return bodySmall;
  }

  List<Widget> _buildChildren(dynamic data) {
    if (data is String) {
      return [
        Text(data, style: context.textTheme.bodyMedium),
      ];
    } else if (data is List) {
      return _buildJsonObjectListView(data, '', 0);
    } else if (data is Map) {
      return _buildJsonMapView(data as Map<String, dynamic>, '', 0);
    }

    return [];
  }
}
