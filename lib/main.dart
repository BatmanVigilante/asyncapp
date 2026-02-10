import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AsyncDemo(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Async Truth (Mutually Exclusive States)
// ─────────────────────────────────────────────────────────────

sealed class AsyncState<T> {
  const AsyncState();
}

class Loading<T> extends AsyncState<T> {
  final T? previous;
  const Loading([this.previous]);
}

class Data<T> extends AsyncState<T> {
  final T value;
  const Data(this.value);
}

class Error<T> extends AsyncState<T> {
  final Object error;
  const Error(this.error);
}

// ─────────────────────────────────────────────────────────────
// State Owner
// ─────────────────────────────────────────────────────────────

class AsyncDemo extends StatefulWidget {
  const AsyncDemo({super.key});

  @override
  State<AsyncDemo> createState() => _AsyncDemoState();
}

class _AsyncDemoState extends State<AsyncDemo> {
  AsyncState<String> state = const Loading();
  int _operationId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final int myOperation = ++_operationId;

    final previousData =
        state is Data<String> ? (state as Data<String>).value : null;

    setState(() {
      state = Loading(previousData);
    });

    final delay = DateTime.now().millisecondsSinceEpoch % 3 + 1;

    try {
      await Future.delayed(Duration(seconds: delay));

      // 🔐 Ownership check
      if (myOperation != _operationId) return;

      setState(() {
        state = Data("Finished in ${delay}s");
      });
    } catch (e) {
      if (myOperation != _operationId) return;

      setState(() {
        state = Error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Async Truth Demo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Center(
        child: switch (state) {
          Loading(:final previous) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (previous != null)
                  Text(
                    previous,
                    style: const TextStyle(fontSize: 20),
                  ),
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ],
            ),
          Data(:final value) => Text(
              value,
              style: const TextStyle(fontSize: 20),
            ),
          Error(:final error) => Text(
              "Error: $error",
              style: const TextStyle(color: Colors.red),
            ),
        },
      ),
    );
  }
}