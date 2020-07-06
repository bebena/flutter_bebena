import 'package:flutter_bebena/input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Input Validator Test", () {
    var fieldname = "Testing";
    String namaTesting = "Agus Widhiyasa";
    String nomorTesting = "5171020000000001";
    String nomorHandphone = "081234567890";
    String nomorHandphone2 = "+6281234567890";

    test("Tesing Required", () {
      String res = InputValidator.validate("", fieldname, isRequired: true);

      expect("Testing tidak boleh kosong", res);
    });

    test("Testing must be number", () {
      String res = InputValidator.validate("12345abc", fieldname, isRequired: true, isNumber: true);

      expect("Testing harus berupa Angka", res);
    });
  });
}