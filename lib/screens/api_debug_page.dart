// This is a simple Flutter page to debug API responses.
// Delete later.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiDebugPage extends StatefulWidget {
  const ApiDebugPage({super.key});

  @override
  State<ApiDebugPage> createState() => _ApiDebugPageState();
}

class _ApiDebugPageState extends State<ApiDebugPage> {
  String _response = "Press the button to fetch data";

  Future<void> fetchApiData() async {
    final url = Uri.parse(
        "https://api.data.gov.in//resource/35985678-0d79-46b4-9ed6-6f13308a1d24?api-key=579b464db66ec23bdd000001ffd44385f3ab478276f8b2a9242419b5&format=json&limit=50&filters[State]=Punjab"); // replace with your API
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          _response = const JsonEncoder.withIndent('  ')
              .convert(json.decode(res.body));
        });
      } else {
        setState(() {
          _response = "Error: ${res.statusCode}\n${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Exception: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Debug Page")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: SelectableText(
            _response,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchApiData,
        child: const Icon(Icons.cloud_download),
      ),
    );
  }
}
