import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/network/dio_app_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DioAppClient client;
  final requestOptions = RequestOptions(path: 'chamados');

  void stubGetError(DioExceptionType type, {Response<dynamic>? response}) {
    when(() => dio.get<dynamic>(any())).thenThrow(
      DioException(
        requestOptions: requestOptions,
        type: type,
        response: response,
      ),
    );
  }

  setUp(() {
    dio = MockDio();
    client = DioAppClient(dio);
  });

  group('DioAppClient', () {
    test('Decodifica resposta JSON recebida como texto', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: requestOptions,
          statusCode: 200,
          data: '{"sucesso": true}',
        ),
      );

      expect(await client.get('chamados'), {'sucesso': true});
    });

    test(
      'Converte status 401 em UnauthorizedException com a mensagem da API',
      () {
        stubGetError(
          DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 401,
            data: {'sucesso': false, 'mensagem': 'Token inválido.'},
          ),
        );

        expect(
          client.get('chamados'),
          throwsA(
            isA<UnauthorizedException>().having(
              (e) => e.message,
              'message',
              'Token inválido.',
            ),
          ),
        );
      },
    );

    test('Converte falha de conexão em NetworkException', () {
      stubGetError(DioExceptionType.connectionError);

      expect(client.get('chamados'), throwsA(isA<NetworkException>()));
    });

    test('Converte timeout em NetworkException', () {
      stubGetError(DioExceptionType.receiveTimeout);

      expect(client.get('chamados'), throwsA(isA<NetworkException>()));
    });
  });
}
