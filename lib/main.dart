import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:direct_link/direct_link.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Direct Link Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 130, 240, 187)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Direct Link Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>>? links;
  bool isLoading = false; // Added loading indicator flag.

  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showSupportedLinksDialog(context);
            },
            icon: const Icon(
              Icons.info,
              size: 30,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onPressed,
                child: const Text('Generate Direct Link'),
              ),
              const ElevatedButton(
                onPressed: joinTelegram,
                child: Text('Join Telegram'),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? const CircularProgressIndicator() // Show loading indicator.
              : links != null
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: links!.length,
                        itemBuilder: (context, index) {
                          var link = links![index];
                          return Card(
                            child: ListTile(
                              title: Text('${link['quality']}p'),
                              subtitle: Text(link['type']),
                              trailing: IconButton(
                                icon: const Icon(Icons.content_copy),
                                onPressed: () {
                                  copyToClipboard(link['link']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Link copied to clipboard'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),
        ],
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(2.0),
        child: Text(
          'Developed by AdityaDev',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // onPressed() function to generate the direct link.
  Future<void> onPressed() async {
    setState(() {
      isLoading = true; // Set loading to true before fetching data.
    });

    var directLink = DirectLink();

    var url = urlController.text;

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid URL'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false; // Set loading to false when the input is invalid.
      });
      return;
    }

    var model = await directLink.check(url);

    if (model == null) {
      // ignore: avoid_print
      print('model is null');
      setState(() {
        isLoading = false; // Set loading to false when there is an error.
      });
      return;
    }

    setState(() {
      links = model.links
          ?.map((link) => {
                'quality': link.quality,
                'type': link.type,
                'link': link.link,
              })
          .toList();
      isLoading = false; // Set loading to false after fetching data.
    });
  }

  // To copy the generated links.
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}

// To launch the url.
Future<void> joinTelegram() async {
  final Uri url = Uri.parse('https://telegram.me/VikiMediaOfficial/');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

// To show the dialog box.
void showSupportedLinksDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Supported Links'),
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stylingText('- Facebook'),
            stylingText('- Instagram'),
            stylingText('- Youtube'),
            stylingText('- Twitter'),
            stylingText('- Dailymotion'),
            stylingText('- Vimeo'),
            stylingText('- VK'),
            stylingText('- SoundCloud'),
            stylingText('- Tiktok'),
            stylingText('- Reddit'),
            stylingText('- Threads'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

// To Style the text.
Widget stylingText(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16.0),
    ),
  );
}
