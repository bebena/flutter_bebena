import 'package:flutter/material.dart';

import '../helpers.dart';

enum LabelType {
  heading1, heading2, heading3, heading4, heading5, heading6, caption,
  harga, subtitle1, subtitle2, button, bodyText1, bodyText2,
  subtitle, secondarySubTitle, captionLower,
  listTitle, listTitleSmall, overline
}

/// Penyerderhanaan Text dari flutter agar mudah dipanggil
///
/// Style mengikuti Material Design guidelines, dengan beberapa perbaikan style
class Label extends StatelessWidget {
  final String text;
  final EdgeInsets margin;
  final LabelType type;
  final double fontSize;
  final Color color;
  final double marginBottom;
  final FontWeight fontWeight;
  final textAlign;

  Label(this.text, {
    this.margin,
    this.type = LabelType.bodyText1,
    this.fontSize,
    this.color,
    this.marginBottom,
    this.fontWeight,
    this.textAlign = TextAlign.start,
    this.maxLine
  });

  final int maxLine;

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    String textLabel = text;
    switch (type) {
      case LabelType.heading1:
        style = Theme.of(context).textTheme.headline1;
        break;
      case LabelType.heading2:
        style = Theme.of(context).textTheme.headline2;
        break;
      case LabelType.heading3:
        style = Theme.of(context).textTheme.headline3;
        break;
      case LabelType.heading4:
        style = Theme.of(context).textTheme.headline4;
        break;
      case LabelType.heading5:
        style = Theme.of(context).textTheme.headline5;
        break;
      case LabelType.heading6:
        style = Theme.of(context).textTheme.headline6.copyWith(
          color: Theme.of(context).accentColor
        );
        break;
      case LabelType.captionLower:
        bool darkMode = Helpers.isDarkMode(context);
        style = Theme.of(context).textTheme.caption.copyWith(color: (darkMode) ? Colors.grey.shade300 : Colors.grey.shade500);
        break;
      case LabelType.caption:
        bool darkMode = Helpers.isDarkMode(context);
        textLabel = text.toUpperCase();
        style = Theme.of(context).textTheme.caption.copyWith(color: (darkMode) ? Colors.grey.shade300 : Colors.grey.shade500);
        break;
      case LabelType.harga:
        style = Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.red, fontSize: 18);
        break;
      case LabelType.subtitle1:
        style = Theme.of(context).textTheme.subtitle1;
        break;
      case LabelType.subtitle2:
        style = Theme.of(context).textTheme.subtitle2;
        break;
      case LabelType.button:
        style = Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).accentColor);
        break;
      case LabelType.bodyText1:
        style = Theme.of(context).textTheme.bodyText1;
        break;
      case LabelType.bodyText2:
        style = Theme.of(context).textTheme.bodyText2;
        break;
      case LabelType.listTitle:
        style = Theme.of(context).textTheme.subtitle1.copyWith(color: Theme.of(context).accentColor, fontWeight: FontWeight.w500);
        break;
      case LabelType.listTitleSmall:
        style = Theme.of(context).textTheme.subtitle1.copyWith(
            color: Theme.of(context).accentColor, fontWeight: FontWeight.w500,
          fontSize: 14
        );
        break;
      case LabelType.overline:
        style = Theme.of(context).textTheme.overline;
        break;
      case LabelType.subtitle:
        style = Theme.of(context).textTheme.bodyText1.copyWith(
          color: Theme.of(context).accentColor,
          fontWeight: FontWeight.bold
        );
        break;
      case LabelType.secondarySubTitle:
        style = Theme.of(context).textTheme.caption;
        break;
    }

    if (fontSize != null) {
      style = style.copyWith(fontSize: fontSize);
    }

    if (color != null) {
      style = style.copyWith(color: color);
    }

    if (fontWeight != null)
      style = style.copyWith(fontWeight: fontWeight);

    EdgeInsets emargin = EdgeInsets.zero;
    if (marginBottom != null) {
      emargin = EdgeInsets.only(bottom: marginBottom);
    } else if (margin != null) {
      emargin = margin;
    }

    return Container(
      margin: emargin,
      child: Text(textLabel, textAlign: textAlign, maxLines: maxLine ?? null, overflow: maxLine == null ? null : TextOverflow.ellipsis, style: style),
    );
  }
}