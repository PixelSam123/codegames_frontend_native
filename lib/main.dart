import 'dart:convert';
import 'dart:io';

import 'package:codegames_frontend_native/types.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'codegames',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _serverUrl = TextEditingController();
  Future<List<UserPreview>>? _leaderboard;
  Future<List<ProblemPreview>>? _problems;

  @override
  void dispose() {
    _serverUrl.dispose();
    super.dispose();
  }

  void fetchLeaderboardAndProblems() {
    _leaderboard = () async {
      final res =
          await http.get(Uri.parse('${_serverUrl.text}/problems/v1/problem'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return (jsonDecode(res.body) as List<Map<String, dynamic>>)
          .map((element) => UserPreview.fromJson(element))
          .toList();
    }();

    _problems = () async {
      final res = await http.get(Uri.parse('${_serverUrl.text}/user/v1'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return (jsonDecode(res.body) as List<Map<String, dynamic>>)
          .map((element) => ProblemPreview.fromJson(element))
          .toList();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('codegames'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serverUrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'Server URL',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  height: 43.0,
                  child: ElevatedButton(
                    onPressed: fetchLeaderboardAndProblems,
                    child: const Text('Load'),
                  ),
                ),
              ],
            ),
            _leaderboard == null
                ? const Text('Leaderboard not loaded')
                : FutureBuilder(
                    future: _leaderboard,
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.toString());
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      return const CircularProgressIndicator();
                    }),
            _problems == null
                ? const Text('Problems not loaded')
                : FutureBuilder(
                    future: _problems,
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.toString());
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      return const CircularProgressIndicator();
                    }),
          ],
        ),
      ),
    );
  }
}
