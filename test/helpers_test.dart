import 'package:flutter_bebena/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Helper Testing", () {
    test("Testing hari ini", () {
      DateTime time = DateTime.parse("2020-06-29 10:30:00");
      String diff = Helpers.getTimeDifferences(time);

      expect("10:30", diff);
    });

    test("Testing Kemarin", () {
      DateTime time = DateTime.parse("2020-06-28 10:30:00");
      String diff = Helpers.getTimeDifferences(time);

      expect("kemarin", diff.toLowerCase());
    });

    test("Tahun ini", () {
      DateTime time = DateTime.parse("2020-05-20 10:30:00");
      String diff = Helpers.getTimeDifferences(time);

      expect("20 May", diff);
    });

    test("Tahun 2019", () {
      DateTime time = DateTime.parse("2019-08-18 10:30:00");
      String diff = Helpers.getTimeDifferences(time);

      expect("18 August 2019", diff);
    });
  });
}
