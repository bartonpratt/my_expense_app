import '../exports.dart';

class PenniBot extends StatefulWidget {
  const PenniBot({super.key,required this.title});
final String title;

  @override
  State<PenniBot> createState() => _PenniBotState();
}

class _PenniBotState extends State<PenniBot> {
  List<ChatModel> chatList = []; // list of ChatModel objects
  String apiKey = '';

  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),centerTitle: true,
      ),
      body: FlutterGeminiChat(assetPath: "assets/images/bot.png",contentWidget: Text('Hello ${provider.username}'),
        chatContext: 'You are a financial expert',
        chatList: chatList,
        apiKey: apiKey,
      ),
    );
  }
}


