import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JDoodleIdeWidget extends StatefulWidget {
  const JDoodleIdeWidget({Key? key}) : super(key: key);

  @override
  State<JDoodleIdeWidget> createState() => _JDoodleIdeWidgetState();
}

class _JDoodleIdeWidgetState extends State<JDoodleIdeWidget> {
  // JDoodle IDE related fields
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isLoading = false;
  String _selectedLanguage = 'C'; // Default language
  final String clientId = 'd16f9711413d99c163af11af6a42ae3b';
  final String clientSecret =
      '5d51ad2c36d5c55da8d6b4842d6a068e3b22ec11cf48b457c3053916f2bb79dc';
  final Map<String, Map<String, String>> _languageOptions = {
    'C': {'code': 'c', 'versionIndex': '4'},
    'C++': {'code': 'cpp', 'versionIndex': '4'},
    'Java': {'code': 'java', 'versionIndex': '4'},
    'Python': {'code': 'python3', 'versionIndex': '4'},
  };

  Future<void> _executeCode() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    final String proxyUrl = 'http://localhost:2001/execute';
    final String script = _codeController.text;
    final String language = _languageOptions[_selectedLanguage]!['code']!;
    final String versionIndex =
        _languageOptions[_selectedLanguage]!['versionIndex']!;

    final Map<String, String> payload = {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'script': script,
      'language': language,
      'versionIndex': versionIndex,
    };

    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _output = result['output'] ?? 'No output received';
        });
      } else {
        setState(() {
          _output = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Exception occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                  _output = '';
                });
              }
            },
            items: _languageOptions.keys
                .map<DropdownMenuItem<String>>((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _codeController,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type your code here...',
            ),
            style: TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _executeCode,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Run Code'),
          ),
          const SizedBox(height: 10),
          Text(
            'Output:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.black87,
            ),
            constraints: BoxConstraints(minHeight: 100),
            child: Text(
              _output.isEmpty ? 'No output yet' : _output,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
