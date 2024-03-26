import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gptgen/features/chatgpt.dart';
import 'package:gptgen/features/dalleai.dart';
import 'package:gptgen/features/textparaphrase.dart';
import 'package:gptgen/features/textsummarization.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Drawer(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
          leading: const Icon(FontAwesomeIcons.image,size: 22,),
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