/// Describes the phone number associated with the [Account]
class PhoneNumber {
  /// The countryCode associated with this phone number
  final String countryCode;

  /// The national number associated with this phone number.
  final String number;

  const PhoneNumber({this.countryCode, this.number});

  /// Constructs a new phone number instance from a [Map].
  ///
  /// This is used mostly internally by this library, but could be useful if
  /// storing the phone number locally by using the [toMap] method.
  PhoneNumber.fromMap(Map<String, dynamic> map)
      : countryCode = map['countryCode'],
        number = map['number'];

  /// Transforms this phone number to a [Map].
  ///
  /// This could be useful for encoding this phone number as JSON and then
  /// storing it locally
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'countryCode': countryCode,
      'number': number,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber &&
          runtimeType == other.runtimeType &&
          countryCode == other.countryCode &&
          number == other.number;

  @override
  int get hashCode => countryCode.hashCode ^ number.hashCode;

  @override
  String toString() => '+$countryCode$number';
}
