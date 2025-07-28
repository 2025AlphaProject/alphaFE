String extractSigunguText(Map<String, dynamic> placeData) {
  final address = placeData['address'] ?? '';
  if (address is String && address.split(' ').length > 1) {
    return address.split(' ')[1];
  }
  return '';
}