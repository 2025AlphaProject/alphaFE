List<dynamic> filterToursByUsername(List<dynamic> allTours, String username) {
  return allTours.where((plan) {
    final users = plan['user'] ?? [];
    return users.any((u) => u['username'] == username);
  }).toList();
}