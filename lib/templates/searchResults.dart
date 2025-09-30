// Sample search results - replace with actual search logic
final List<SearchResult> searchResults = [
  SearchResult(
      name: 'Noordscheschut',
      location: 'Noordscheschut, Nederland',
      distance: '6,2 km'),
  SearchResult(
      name: 'Noordwijk', location: 'Noordwijk, Nederland', distance: '154 km'),
  SearchResult(
      name: 'Noordwolde', location: 'Noordwolde, Nederland', distance: '39 km'),
  SearchResult(
      name: 'Noord-Sleen',
      location: 'Noord-Sleen, Nederland',
      distance: '18 km'),
  SearchResult(
      name: 'Nooitgedacht',
      location: 'Nooitgedacht, Nederland',
      distance: '32 km'),
];

class SearchResult {
  final String name;
  final String location;
  final String distance;

  SearchResult({
    required this.name,
    required this.location,
    required this.distance,
  });
}
