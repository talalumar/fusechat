import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fusechat/components/cloudinary_uploader.dart';
import 'package:fusechat/components/message_bubble.dart';
import 'package:fusechat/services/notification_services.dart';
import 'package:fusechat/services/get_server_key.dart';
import 'package:fusechat/services/gemini_service.dart';

class ChartScreen extends StatefulWidget {

  final String chatId;
  final String reciverId;
  final String reciverEmail;

  ChartScreen({required this.chatId, required this.reciverId, required this.reciverEmail});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  TextEditingController messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isGeminiTyping = false;

  void sendMessage ()async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final isGeminiChat = widget.reciverId == 'gemini_ai';

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'text': messageController.text.trim(),
      'senderId': currentUser!.uid,
      'receiverId': widget.reciverId,
      'timestamp': Timestamp.now(),
    });
    messageController.clear();

    // 2. If Gemini, get AI response
    if (isGeminiChat) {
      setState(() {
        isGeminiTyping = true; // Start typing indicator
      });

      final aiResponse = await GeminiService.getGimniResponse(text);

      // Add Gemini's message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': aiResponse,
        'senderId': 'gemini_ai',
        'receiverId': currentUser!.uid,
        'timestamp': Timestamp.now(),
      });
      setState(() {
        isGeminiTyping = false; // Stop typing indicator
      });
    } else {
      // 🔔 Send push notification to real user
      await _sendPushNotification(text);
    }
  }

  final CloudinaryUploader uploader = CloudinaryUploader();

  void _onImageSend() async{
    final mediaUrl = await uploader.pickAndUploadImageorVideo();

    if(mediaUrl != null){
      final isVideo = mediaUrl.contains('.mp4') || mediaUrl.contains('.mov');
      final messageType = isVideo ? 'video' : 'image';

      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
        'mediaUrl': mediaUrl,
        'senderId': currentUser!.uid,
        'receiverId': widget.reciverId,
        'timestamp': Timestamp.now(),
        'type': messageType,
      });
      // 🔔 Send push notification
      await _sendPushNotification("📷 Sent a ${isVideo ? 'video' : 'photo'}");
    }else{
      print('Image not selected or upload failed');
    }
  }

  Future<void> _sendPushNotification(String messageBody) async {
    try {
      // 1. Get receiver's FCM token from Firestore
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.reciverId)
          .get();

      final receiverToken = receiverDoc['fcmToken'];

      if (receiverToken != null && receiverToken.isNotEmpty) {
        // 2. Get access token for HTTP v1 API
        final accessToken = await GetServerKey().getServerKeyToken();

        // 3. Send the notification
        await NotificationService.sendPushNotification(
          token: receiverToken,
          title: currentUser!.email!.replaceAll('@gmail.com', '') ?? "New Message",
          body: messageBody,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.reciverEmail,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: MessageList(widget: widget, isGeminiTyping: isGeminiTyping),
            ),
        
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                      onPressed: _onImageSend,
                      icon: Icon(Icons.image, color: Colors.blueAccent,),
                  ),
                  Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                          ),
                        ),
                      ),
                  ),
                  SizedBox(width: 8,),
                  Material(
                    color: Colors.blueAccent,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: (){
                        sendMessage();
                      },
                      customBorder: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white, size: 20,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.widget,
    required this.isGeminiTyping,
  });

  final ChartScreen widget;
  final bool isGeminiTyping;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent,),);
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return Center(child: Text('No message yet'),);
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            itemCount: isGeminiTyping && widget.reciverId == 'gemini_ai' ? messages.length + 1 : messages.length,
              itemBuilder: (context, index){
                // If it's the first item and Gemini is typing, show typing bubble
                if (isGeminiTyping && widget.reciverId == 'gemini_ai' && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Gemini is typing...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                //  Adjust index if Gemini is typing
                final messageIndex = isGeminiTyping && widget.reciverId == 'gemini_ai'
                    ? index - 1
                    : index;
                final message = messages[messageIndex];

                return MessageBubble(
                  text: (message.data() as Map<String, dynamic>).containsKey('text') ? message['text'] : '',
                  mediaUrl: (message.data() as Map<String, dynamic>).containsKey('mediaUrl') ? message['mediaUrl'] : null,
                  isMe: message['senderId'] == FirebaseAuth.instance.currentUser!.uid,
                  type: (message.data() as Map<String, dynamic>).containsKey('type') ? message['type'] : 'text',
                );
              },
          );
        }
    );
  }
}

