extension type WinLossRecord(
    (
      MatchWins matchWins,
      MatchLosses matchLosses,
      MapWins mapWins,
      MapLosses mapLosses,
      MapDraws mapDraws,
    ) _map) {
  factory WinLossRecord.fromJson(Map<String, dynamic> json) {
    return WinLossRecord(
      (
        MatchWins(json['wins']),
        MatchLosses(json['losses']),
        MapWins(json['map_wins']),
        MapLosses(json['map_losses']),
        MapDraws(json['map_draws']),
      ),
    );
  }

  MatchWins get matchWins => _map.$1;
  MatchLosses get matchLosses => _map.$2;
  MapWins get mapWins => _map.$3;
  MapLosses get mapLosses => _map.$4;
  MapDraws get mapDraws => _map.$5;
}

extension type const MapDifferential._(int value) {
  static const MapDifferential zero = MapDifferential._(0);

  factory MapDifferential(MapWins wins, MapLosses losses) =>
      MapDifferential._(wins - losses);

  MapDifferential operator +(MapDifferential other) =>
      MapDifferential._(value + other.value);
}

extension type const MatchDifferential._(int value) {
  static const MatchDifferential zero = MatchDifferential._(0);

  factory MatchDifferential(MatchWins wins, MatchLosses losses) =>
      MatchDifferential._(wins - losses);

  MatchDifferential operator +(MatchDifferential other) =>
      MatchDifferential._(value + other.value);
}

extension type MatchWins(int _) implements int {}
extension type MatchLosses(int _) implements int {}
extension type MapWins(int _) implements int {}
extension type MapLosses(int _) implements int {}
extension type MapDraws(int _) implements int {}
