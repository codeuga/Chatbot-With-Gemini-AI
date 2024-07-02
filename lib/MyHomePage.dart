import 'package:flutter/material.dart';
import 'package:uga_ai/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uga_ai/themenotifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  bool isloading = false;

  callGeminiModel() async {
    try {
      if (_controller.text.isNotEmpty) {
        setState(() {
          _messages.add(
            Message(text: _controller.text, isUser: true),
          );
          isloading = true;
        });

        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: dotenv.env['GOOGLE_API_KEY']!,
        );
        final prompt = _controller.text.trim();
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        setState(() {
          _messages.add(
            Message(text: response.text!, isUser: false),
          );
          isloading = false;
        });
        _controller.clear();
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/robot.png",
                    height: 35,
                    width: 36,
                  ),
                  SizedBox(
                    width: 14,
                  ),
                  Text(
                    "UGA - AI Assistant",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xff3369FF)),
                  ),
                ],
              ),
              GestureDetector(
                child: (currentTheme == ThemeMode.dark)
                    ? Icon(
                        Icons.light_mode,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: message.isUser
                            ? BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                      ),
                      child: SelectableText(
                        message.text,
                        style: message.isUser
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // user input
          Padding(
            padding:
                const EdgeInsets.only(bottom: 32, top: 16, left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      controller: _controller,
                      style: Theme.of(context).textTheme.titleSmall,
                      decoration: InputDecoration(
                        hintText: "Write your message",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: isloading
                        ? CircularProgressIndicator()
                        : GestureDetector(
                            child: Image.asset("assets/send.png"),
                            onTap: callGeminiModel,
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
