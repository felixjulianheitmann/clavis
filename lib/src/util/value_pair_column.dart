
import 'package:flutter/widgets.dart';

class ValuePairColumn extends StatelessWidget {
  const ValuePairColumn({
    super.key,
    required this.labels,
    required this.icons,
    required this.values,
    required this.height,
  });
  final List<String> labels;
  final List<IconData> icons;
  final List<String> values;
  final double height;

  Widget _text(String text, Alignment align) {
    return SizedBox(
      height: height,
      child: Align(alignment: align, child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelTexts = labels.map((e) => _text(e, Alignment.centerRight));

    final iconWidgets = icons.map(
      (e) => SizedBox(height: height, child: Icon(e)),
    );

    final valueTexts = values.map((e) => _text(e, Alignment.centerLeft));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labelTexts.toList(),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: iconWidgets.toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: valueTexts.toList(),
          ),
        ),
      ],
    );
  }
}
