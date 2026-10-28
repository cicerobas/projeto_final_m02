import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/core/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator.haversineKm', () {
    test('Retorna zero para o mesmo ponto', () {
      final distance = DistanceCalculator.haversineKm(
        fromLatitude: -27.100412,
        fromLongitude: -52.615234,
        toLatitude: -27.100412,
        toLongitude: -52.615234,
      );

      expect(distance, 0);
    });

    test('Retorna a distância conhecida entre São Paulo e Rio de Janeiro', () {
      final distance = DistanceCalculator.haversineKm(
        fromLatitude: -23.5505,
        fromLongitude: -46.6333,
        toLatitude: -22.9068,
        toLongitude: -43.1729,
      );

      expect(distance, closeTo(360.75, 0.05));
    });
  });
}
