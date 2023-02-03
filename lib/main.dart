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
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'If you see this text it likely means the server '
              'is still running with Basic auth over HTTP! '
              'So please don\'t use your real credentials.',
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _username,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 43.0,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _normalPadding = 8.0;

  final TextEditingController _serverUrl = TextEditingController();
  Future<List<UserPreview>>? _leaderboard;
  Future<List<ProblemPreview>>? _problems;

  @override
  void dispose() {
    _serverUrl.dispose();
    super.dispose();
  }

  void fetchLeaderboardAndProblems() {
    Future<List<UserPreview>> fetchedLeaderboard = () async {
      http.Response res =
          await http.get(Uri.parse('${_serverUrl.text}/user/v1'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return (jsonDecode(res.body) as List)
          .map((element) => UserPreview.fromJson(element))
          .toList();
    }();

    Future<List<ProblemPreview>> fetchedProblems = () async {
      http.Response res =
          await http.get(Uri.parse('${_serverUrl.text}/problems/v1/problem'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return (jsonDecode(res.body) as List)
          .map((element) => ProblemPreview.fromJson(element))
          .toList();
    }();

    setState(() {
      _leaderboard = fetchedLeaderboard;
      _problems = fetchedProblems;
    });
  }

  void goToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('codegames'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: _normalPadding,
            ),
            child: ElevatedButton(
              onPressed: goToSignUpPage,
              child: const Text('Sign Up'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  const SizedBox(width: _normalPadding),
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
                          return Table(
                            children: [
                              const TableRow(
                                children: [
                                  Text('Name'),
                                  Text('Accepted Submission Count'),
                                ],
                              ),
                              ...snapshot.data!.map((userPreview) => TableRow(
                                    children: [
                                      Text(userPreview.name),
                                      Text(userPreview.acceptedSubmissionCount
                                          .toString()),
                                    ],
                                  )),
                            ],
                          );
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
                          return Column(
                            children: snapshot.data!
                                .map((problemPreview) => Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          _normalPadding,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              problemPreview.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            Text(problemPreview.description),
                                            OutlinedButton(
                                              onPressed: () {},
                                              child: const Text('Go'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }

                        return const CircularProgressIndicator();
                      }),
            ],
          ),
        ),
      ),
    );
  }
}
