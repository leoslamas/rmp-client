class SearchResult {
  String name;
  String seeders;
  String leechers;
  String size;
  String url;

  SearchResult(this.name, this.seeders, this.leechers, this.size, this.url);

  factory SearchResult.fromJson(dynamic json) {
    return SearchResult(
        json['name'] as String,
        json['seeders'] as String,
        json['leechers'] as String,
        json['size'] as String,
        json['url'] as String);
  }
}
