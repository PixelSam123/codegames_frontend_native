import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:codegames_frontend_native/sizes.dart' as sizes;
import 'package:codegames_frontend_native/types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: child!,
      ),
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
  final String serverUrl;

  const SignUpPage({super.key, required this.serverUrl});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  Future<String>? _signUpResult;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void attemptSignUp() {
    Future<String> fetchedSignUpResult = () async {
      http.Response res = await http.post(
        Uri.parse('${widget.serverUrl}/user/v1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _username.text,
          'password': _password.text,
        }),
      );

      if (res.statusCode != HttpStatus.created) {
        throw Exception('Sign up error: ${res.body}');
      }

      return res.body;
    }();

    setState(() {
      _signUpResult = fetchedSignUpResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sizes.largePadding),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 511.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'If you see this text it likely means the server '
                        'is still running with Basic auth over HTTP! '
                        'So please don\'t use your real credentials.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: sizes.largePadding),
                      TextField(
                        controller: _username,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: sizes.normalPadding),
                      TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: sizes.normalPadding),
                      SizedBox(
                        height: sizes.largeButtonHeight(
                          MediaQuery.of(context).textScaleFactor,
                        ),
                        child: ElevatedButton(
                          onPressed: attemptSignUp,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: sizes.normalPadding),
                _signUpResult == null
                    ? const Text('Waiting for sign up attempt')
                    : FutureBuilder(
                        future: _signUpResult,
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return const Text('Successfully signed up');
                          }

                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          return const CircularProgressIndicator();
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProblemPage extends StatefulWidget {
  final String serverUrl;
  final int idx;

  const ProblemPage({super.key, required this.serverUrl, required this.idx});

  @override
  State<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late Future<ProblemDetailedView> _problem;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _problem = () async {
      http.Response res = await http.get(
          Uri.parse('${widget.serverUrl}/problems/v1/problem/${widget.idx}'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return ProblemDetailedView.fromJson(jsonDecode(res.body));
    }();
    super.initState();
  }

  void goToSubmissionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmissionPage(
          serverUrl: widget.serverUrl,
          idx: widget.idx,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sizes.largePadding),
          child: FutureBuilder(
            future: _problem,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(
                      snapshot.data!.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: sizes.normalPadding),
                    TextButton(
                      onPressed: goToSubmissionPage,
                      child: const Text('View submissions for this challenge'),
                    ),
                    const SizedBox(height: sizes.normalPadding),
                    MarkdownBody(data: snapshot.data!.description),
                    const SizedBox(height: sizes.normalPadding),
                    const Text('Copy the initial code below:'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(sizes.normalPadding),
                        child: SelectableText(
                          snapshot.data!.initialCode,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: sizes.normalPadding),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 511.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'You can submit without username and password '
                            'but your submission won\'t be saved.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: sizes.largePadding),
                          TextField(
                            controller: _username,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: 'Username',
                            ),
                          ),
                          const SizedBox(height: sizes.normalPadding),
                          TextField(
                            controller: _password,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: 'Password',
                            ),
                          ),
                          const SizedBox(height: sizes.normalPadding),
                          SizedBox(
                            height: sizes.largeButtonHeight(
                              MediaQuery.of(context).textScaleFactor,
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class SubmissionPage extends StatefulWidget {
  final String serverUrl;
  final int idx;

  const SubmissionPage({super.key, required this.serverUrl, required this.idx});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  late Future<List<Submission>> _submission;

  @override
  void initState() {
    _submission = () async {
      http.Response res = await http.get(Uri.parse(
          '${widget.serverUrl}/problems/v1/submission/${widget.idx}'));

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Network response not OK! ${res.statusCode}');
      }

      return (jsonDecode(res.body) as List)
          .map((e) => Submission.fromJson(e))
          .toList();
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submissions for this challenge'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sizes.largePadding),
          child: FutureBuilder(
            future: _submission,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data!
                      .map((submission) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                sizes.normalPadding,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${submission.username}: ${submission.status}',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: sizes.normalPadding),
                                  Text(
                                    submission.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          fontFamily: 'monospace',
                                        ),
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
            },
          ),
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
        builder: (_) => SignUpPage(serverUrl: _serverUrl.text),
      ),
    );
  }

  void goToProblemPage(int idx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProblemPage(serverUrl: _serverUrl.text, idx: idx),
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
              horizontal: sizes.largePadding,
              vertical: sizes.normalPadding,
            ),
            child: TextButton(
              onPressed: goToSignUpPage,
              child: const Text('Sign Up'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(sizes.largePadding),
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
                  const SizedBox(width: sizes.normalPadding),
                  SizedBox(
                    height: sizes.largeButtonHeight(
                      MediaQuery.of(context).textScaleFactor,
                    ),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:
                                snapshot.data!.asMap().entries.map((entry) {
                              int idx = entry.key;
                              ProblemPreview problemPreview = entry.value;

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    sizes.normalPadding,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        problemPreview.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(
                                        height: sizes.normalPadding,
                                      ),
                                      MarkdownBody(
                                        data: problemPreview.description,
                                      ),
                                      const SizedBox(
                                        height: sizes.normalPadding,
                                      ),
                                      ElevatedButton(
                                        onPressed: () => goToProblemPage(idx),
                                        child: const Text('Go'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
