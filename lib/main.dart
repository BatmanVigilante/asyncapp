import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const AsyncDemo());
  }
}

//AsyncState (Mutually Exclusive States)
sealed class AsyncState<T> {
  const AsyncState();
}

class Loading<T> extends AsyncState<T> {
  const Loading();
}

class Data<T> extends AsyncState<T> {
  final T value;
  const Data(this.value);
}

class Error<T> extends AsyncState<T> {
  final Object error;
  const Error(this.error);
}

//State Owner
class AsyncDemo extends StatefulWidget {
  const AsyncDemo({super.key});
  @override
  State<AsyncDemo> createState() => _AsyncDemoState();
}

//Owner
class _AsyncDemoState extends State<AsyncDemo> {
  AsyncState<String> state = const Loading();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        state = const Data("Hello from the future(2s)");
      });
    } catch (e) {
      setState(() {
        state = Error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFromState();
  }

  Widget _buildFromState() {
    return Scaffold(
      appBar: AppBar(title: const Text("Async Truth Demo")),
      body: Center(
        child: switch (state) {
          Loading() => const CircularProgressIndicator(),
          Data(:final value) => Text(
            value,
            style: const TextStyle(fontSize: 20),
          ),
          Error(:final error) => Text(
            "Error:$error",
            style: const TextStyle(color: Colors.red),
          ),
        },
      ),
    );
  }
}
