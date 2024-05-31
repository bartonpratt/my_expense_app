library flutter_gemini_bot;
import 'package:penniverse/exports.dart';



class FlutterGeminiChat extends StatefulWidget {
  const FlutterGeminiChat({
    Key? key,
    required this.chatContext,
    required this.chatList,
    required this.apiKey,
    required this.assetPath,
    required this.contentWidget,
    this.hintText = "Ask your questions...",
    this.buttonColor = primaryColor,
    this.errorMessage = "an error occurred, please try again later",
    this.botChatBubbleColor = primaryColor,
    this.userChatBubbleColor = secondaryColor,
    this.botChatBubbleTextColor = Colors.black,
    this.userChatBubbleTextColor = Colors.black,
    this.loaderWidget = const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    ),
    this.onRecorderTap,
  }) : super(key: key);

  /// The context of the chat.
  final String chatContext;

  /// The list of chat models.
  final List<ChatModel> chatList;

  /// The API key for the chat get it on https://ai.google.dev/.
  final String apiKey;

  /// The path to the asset image.
  final String assetPath;

  /// The content widget to be displayed below the image.
  final Widget contentWidget;

  /// The hint text for the chat input field.
  final String hintText;

  /// The color of the chat button.
  final Color buttonColor;

  /// The error message to be displayed in case of an error.
  final String errorMessage;

  /// The color of the chat bubble for the bots messages.
  final Color botChatBubbleColor;

  /// The color of the chat bubble for the user's messages.
  final Color userChatBubbleColor;

  ///The color of text chat bubble for the bots messages.
  final Color botChatBubbleTextColor;

  ///The color of text chat bubble for the users messages.
  final Color userChatBubbleTextColor;

  /// The loader widget to be displayed in the chat body.
  final Widget loaderWidget;

  /// Recorder button onTap callback.
  final VoidCallback? onRecorderTap;

  @override
  _FlutterGeminiChatState createState() => _FlutterGeminiChatState();
}

class _FlutterGeminiChatState extends State<FlutterGeminiChat> {
  List<Map<String, String>> messages = [];

  final TextEditingController questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.add({"text": widget.chatContext});
  }

  @override
  void dispose() {
    questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.chatList.isEmpty
              ? BodyPlaceholderWidget(
            assetPath: widget.assetPath,
            contentWidget: widget.contentWidget,
          )
              : chatBody(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: texFieldBottomWidget(),
        ),
      ],
    );
  }

  Padding chatBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.chatList.length,
        itemBuilder: (context, index) => ChatItemCard(
          botChatBubbleColor: widget.botChatBubbleColor,
          userChatBubbleColor: widget.userChatBubbleColor,
          chatItem: widget.chatList[index],
          onTap: () {
            showToolsDialog(context, index);
          },
        ),
      ),
    );
  }

  Future<dynamic> showToolsDialog(BuildContext context, int index) {
    return customDialog(
      context: context,
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: widget.chatList[index].message));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: primaryColor,
                  duration: Duration(milliseconds: 400),
                  content: Text('Copied to Clipboard'),
                ),
              );
            },
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
          ),
          ListTile(
            onTap: () {
              setState(() {
                widget.chatList.removeAt(index);
              });
              Navigator.pop(context);
            },
            leading: const Icon(Icons.delete),
            title: const Text("Delete"),
          ),
          ListTile(
            onTap: () {
              setState(() {
                questionController.text = widget.chatList[index].message;
                questionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: questionController.text.length));
              });
              Navigator.pop(context);
            },
            leading: const Icon(Icons.add),
            title: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  Widget texFieldBottomWidget() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(
          left: appPadding, right: appPadding, top: appPadding + 8),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          hintText: widget.hintText,
          suffixIcon: questionController.text.isEmpty
              ? InkWell(
            onTap: widget.onRecorderTap,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: secondaryColor),
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
              : InkWell(
            onTap: () async {
              var question = questionController.text.trim();

              if (question.isEmpty) return;

              setState(() {
                widget.chatList.add(ChatModel(
                    chat: 0,
                    message: question,
                    time:
                    "${DateTime.now().hour}:${DateTime.now().second}"));

                widget.chatList.add(ChatModel(
                    chatType: ChatType.loading,
                    chat: 1,
                    message: "",
                    time: ""));

                questionController.clear();
              });

              messages.add({"text": question});

              try {
                var (responseString, response) =
                await GeminiApi.geminiChatApi(
                    messages: messages, apiKey: widget.apiKey);

                setState(() {
                  widget.chatList.removeWhere(
                          (chat) => chat.chatType == ChatType.loading);

                  if (response.statusCode == 200) {
                    widget.chatList.add(ChatModel(
                        chat: 1,
                        message: responseString,
                        time:
                        "${DateTime.now().hour}:${DateTime.now().second}"));

                    messages.add({"text": responseString});
                  } else {
                    widget.chatList.add(ChatModel(
                        chat: 0,
                        chatType: ChatType.error,
                        message: widget.errorMessage,
                        time:
                        "${DateTime.now().hour}:${DateTime.now().second}"));
                  }
                });

                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              } catch (e) {
                print("Error: $e");
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: widget.buttonColor),
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          labelStyle: const TextStyle(fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        controller: questionController,
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }
}


/// A placeholder widget for the body of the Gemini Bot.
///
/// This widget displays a centered column with an icon and a text.
/// It is typically used as a placeholder while the actual body content is being loaded.
class BodyPlaceholderWidget extends StatelessWidget {
  final String assetPath;
  final Widget contentWidget;

  const BodyPlaceholderWidget({
    Key? key,
    required this.assetPath,
    required this.contentWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(assetPath),
          ),
          contentWidget,
        ],
      ),
    );
  }
}

