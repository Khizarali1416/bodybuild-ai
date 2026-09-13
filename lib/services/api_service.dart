import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to localhost,
  // or localhost for iOS simulator/Web.
  // Update this depending on the platform you are running on.
  static const String _baseUrl = 'http://127.0.0.1:3000/api';

  Stream<String> streamChat(String message, List<Map<String, dynamic>> history) async* {
    final client = http.Client();
    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/stream'));
    
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'message': message,
      'history': history,
    });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        yield '[Error connecting to server. Code: ${response.statusCode}]';
        return;
      }

      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in stream) {
        if (line.isEmpty) continue;
        
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') {
            break;
          }
          
          try {
            final parsed = jsonDecode(data);
            if (parsed['chunk'] != null) {
              yield parsed['chunk'];
            } else if (parsed['error'] != null) {
              yield '\n\n[Error: ${parsed['error']}]';
            }
          } catch (e) {
            // Ignore parse errors for malformed lines
          }
        }
      }
    } catch (e) {
      yield '\n\n[Connection Error: Please check if the backend server is running.]';
    } finally {
      client.close();
    }
  }
}
