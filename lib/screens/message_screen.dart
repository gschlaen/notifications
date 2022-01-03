import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments ?? 'No Data';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('$args', style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}
