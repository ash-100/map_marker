class MarkerData {
  final String markerId;
  final String latitude;
  final String longitude;
  final String labelName;
  MarkerData(
      {required this.markerId,
      required this.latitude,
      required this.longitude,
      required this.labelName});

  Map<String, dynamic> toMap() {
    return {
      'markerId': markerId,
      'latitude': latitude,
      'longitude': longitude,
      'labelName': labelName,
    };
  }
}
