import 'package:gptgen/chatgpt.dart';
import 'package:flutter/material.dart';
import 'package:gptgen/dalleai.dart';
import 'package:gptgen/textparaphrase.dart';
import 'package:gptgen/textsummarization.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:gptgen/themes/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            title: 'GPTGen',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            home: const ChatGPTScreen(),
          );
        },
      );
}

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            const Divider(color: Colors.black54),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: 20 + MediaQuery.of(context).padding.top,
          bottom: 15,
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            changed != false
                ? Image.asset('assets/images/white_logo.png', scale: 18)
                : Image.asset('assets/images/black_logo.png', scale: 18),
            const SizedBox(height: 20),
            const Text('Made By Ashwin', style: TextStyle(fontSize: 15)),
          ],
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.mark_unread_chat_alt_outlined),
              title: const Text('ChatGPT'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ChatGPTScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Dall-E AI'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const DallEAIScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.published_with_changes_outlined),
              title: const Text('Text Paraphrase'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const TextParaphrase()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Text Summarize'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const TextSummarize()));
              },
            ),
          ],
        ),
      );
}
