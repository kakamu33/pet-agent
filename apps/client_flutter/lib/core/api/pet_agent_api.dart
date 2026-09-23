import 'package:dio/dio.dart';

class PetAgentApi {
  PetAgentApi({required String baseUrl, required String userId})
      : _userId = userId,
        _client = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _client;
  final String _userId;

  Future<Map<String, dynamic>> getPetState() async {
    final response = await _client.get<Map<String, dynamic>>('/v1/pet/state');
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String content,
    String? conversationId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/v1/chat/messages',
      data: {
        'content': content,
        if (conversationId != null) 'conversation_id': conversationId,
      },
      options: Options(headers: {'X-User-Id': _userId}),
    );
    return response.data ?? const {};
  }
}

