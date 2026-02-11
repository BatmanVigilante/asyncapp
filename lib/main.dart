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
// Async Controller (Owns Time + Truth)
// ─────────────────────────────────────────────────────────────

class AsyncController extends ChangeNotifier {
  AsyncState<String> state = const Loading();
  int _operationId = 0;

  Future<void> load() async {
    final int myOperation = ++_operationId;

    final previousData =
        state is Data<String> ? (state as Data<String>).value : null;

    state = Loading(previousData);
    notifyListeners();

    final delay = DateTime.now().millisecondsSinceEpoch % 3 + 1;

    try {
      await Future.delayed(Duration(seconds: delay));

      // 🔐 Ownership check
      if (myOperation != _operationId) return;

      state = Data("Finished in ${delay}s");
      notifyListeners();
    } catch (e) {
      if (myOperation != _operationId) return;

      state = Error(e);
      notifyListeners();
    }
  }
}

// ─────────────────────────────────────────────────────────────
// UI (Pure Projection of Truth)
// ─────────────────────────────────────────────────────────────

class AsyncDemo extends StatefulWidget {
  const AsyncDemo({super.key});

  @override
  State<AsyncDemo> createState() => _AsyncDemoState();
}

class _AsyncDemoState extends State<AsyncDemo> {
  late final AsyncController controller;

  @override
  void initState() {
    super.initState();
    controller = AsyncController();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Async Truth Demo"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.load,
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
      },
    );
  }
}
