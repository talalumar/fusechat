import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusechat/screens/chart_screen.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Fuse Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
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
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(user['email'][0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Hey there! I\'m using FuseChat',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
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
    );
  }
}
