import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/screens/chart_screen.dart';
import 'package:fusechat/screens/welcome_screen.dart';
import 'package:fusechat/services/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class UsersScreen extends StatefulWidget {
  static const String id = 'users_screen';

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  
  final currentUser = FirebaseAuth.instance.currentUser;

  String getChatId(String user1, String user2){
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  @override
  void initState() {
    super.initState();

    // Request permissions
    FirebaseMessaging.instance.requestPermission();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showNotification(message);
    });

    // App opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 App opened from notification');
    });
  }

  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 4)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Press back again to exit', style: TextStyle(color: Colors.black),),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 6,
            ),
          );
        } else {
          SystemNavigator.pop(); // exit app (not await since this is not async)
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF419cd7),
          // centerTitle: true,
          title: Text('Fuse Chat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () async{
                 await FirebaseAuth.instance.signOut();
                 await FirebaseMessaging.instance.deleteToken();
      
                 Navigator.pushReplacementNamed(context, WelcomeScreen.id);
                },
                icon: Icon(Icons.logout, color: Colors.white,),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator(
                  color: Color(0xFF419cd7),
                ),);
              }
      
              final users = snapshot.data!.docs;
      
              return ListView.builder(
                itemCount: users.length,
                  itemBuilder: (context, index){
                    final user = users[index];
                    if(user['uid'] == currentUser!.uid) return Container();
      
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: user['uid'] == 'gemini_ai' ? Colors.white : Color(0xFF419cd7),
                            backgroundImage: user['uid'] == 'gemini_ai'
                                ? AssetImage('images/meta.png') // Add an AI icon here
                                : null,
                            child: user['uid'] != 'gemini_ai'
                                ? Text(user['email'][0].toUpperCase(), style: TextStyle(color: Colors.white))
                                : null,
                          ),
                          title: Text(user['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: user['uid'] != 'gemini_ai'
                              ? Text(
                             'Hey there! I\'m using FuseChat',
                            style: TextStyle(color: Colors.grey[600]),
                          ): null,
                          onTap: (){
                            final selectedUserId = user['uid'];
                            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                            final chatId = getChatId(currentUserId, selectedUserId);
      
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ChartScreen(
                                  chatId: chatId,
                                  reciverEmail: user['email'],
                                  reciverId: selectedUserId,
                                )));
                          },
                        ),
                      ),
                    );
                  }
              );
            },
        ),
      ),
    );
  }
}
