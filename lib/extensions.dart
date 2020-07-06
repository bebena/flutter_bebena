import 'package:intl/intl.dart';

extension IntegerExtension on num {

  /// Format number to Rupiah currency
  String toIDR({int decimalDigits = 0}) {
    var nf = NumberFormat.currency(
        locale: "id_ID",
        symbol: "Rp ",
        decimalDigits: decimalDigits
    );
    return nf.format(this);
  }

  DateTime formatDateFromEpoc() {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
  }
}

extension DateTimeExt on DateTime {
  String formatDate({ String format = "d MMMM y HH:mm" }) {
    var formatter = DateFormat(format);
    return formatter.format(this);
  }
}

extension StringExt on String {
  String formatDate({ String format = "d MMMM y HH:mm" }) {
    if (this.length > 0) {
      var dateTime = DateTime.parse(this);
      var formatter = DateFormat(format);
      return formatter.format(dateTime);
    } else {
      return "";
    }
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndex<T>(T f(E e, int i)) {
    var i = 0;
    return this.map((e) => f(e, i++));
  }

  void forEachIndex(void f(E e, int i)) {
    var i = 0;
    this.forEach((e) => f(e, i++));
  }
}