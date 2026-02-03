import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/add_notes_screen.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotesScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .where('author', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!asyncSnapshot.hasData) {
            return const Center(child: Text('Error! no notes here'));
          }

          if (asyncSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Notes! Click + to add more notes'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView.builder(
              itemCount: asyncSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var note = asyncSnapshot.data!.docs[index];
                var noteId = note.id;

                return Dismissible(
                  key: Key(noteId),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),

                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNotesScreen(
                            noteId: noteId,
                            title: note['title'],
                            description: note['description'],
                          ),
                        ),
                      );
                      return false;
                    } else {
                      await FirebaseFirestore.instance
                          .collection("notes")
                          .doc(noteId)
                          .delete();
                      return true;
                    }
                  },

                  child: Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        note['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        note['description'],
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.clip,
                      ),
                      trailing: Text(
                        DateFormat(
                          'hh:mm a',
                        ).format((note['timestamp'] as Timestamp).toDate()),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
