import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void sendMessage ()async {
    if (messageController.text
        .trim()
        .isEmpty) return;

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'text': messageController.text.trim(),
      'senderId': currentUser!.uid,
      'receiverId': widget.reciverId,
      'timestamp': Timestamp.now(),
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent,),);
                      }
                      if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                        return Center(child: Text('No message yet'),);
                      }
                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                          itemBuilder: (context, index){
                            final message = messages[index];
                            return MessageBubble(
                              text: message['text'],
                              isMe: message['senderId'] == FirebaseAuth.instance.currentUser!.uid,
                            );
                          },
                      );
                    }
                ),
            ),
        
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                      onPressed: (){},
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


class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
