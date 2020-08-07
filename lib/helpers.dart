import 'package:flutter/material.dart';

import 'extensions.dart';

class Helpers {
  Helpers._();

  /// Get time difference with [timeToCompare].
  /// 
  /// When [timeToCompare] is one its means yesterday "Kemarin"
  /// 
  /// When [timeToCompare] is zero or same day, display only hours an minutes
  /// 
  /// When [timeToCompare] greater than 1 and below 365 (one year) display only date and month
  /// 
  /// Other than that display full date format "Day Month Year"
  static String getTimeDifferences(DateTime timeToCompare) {
    final dateNow = DateTime.now();
    final diffTime = dateNow.difference(timeToCompare).inDays;
    final yearNow = dateNow.year;
    final yearCompare = timeToCompare.year;

    if (diffTime == 0) {
      return timeToCompare.formatDate(format: "HH:mm");
    } else if (diffTime == 1) {
      return "Kemarin";
    } else if ((diffTime > 1 && diffTime < 365) && (yearNow == yearCompare)) {
      return timeToCompare.formatDate(format: "dd MMMM HH:mm");
    } else {
      return timeToCompare.formatDate(format: "dd MMMM yyyy HH:mm");
    }
  }

  /// Simplified calling [`Navigator.push()`],
  /// 
  /// Example:
  /// ```
  ///   Helpers.pushTo(context, (context) => WidgetNavigateTo());
  /// ```
  static void pushTo(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push(MaterialPageRoute(builder: builder));

  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}