import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNotesScreen extends StatefulWidget {
  final String? noteId;
  final String? title;
  final String? description;

  const AddNotesScreen({super.key, this.noteId, this.title, this.description});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool get _isEditing => widget.noteId != null;

  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final notesCollection = FirebaseFirestore.instance.collection("notes");
      final timestamp = DateTime.now();

      if (_isEditing) {
        await notesCollection.doc(widget.noteId).update({
          "title": title,
          "description": description,
          "timestamp": timestamp,
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Note Updated!")));
        }
      } else {
        await notesCollection.add({
          "title": title,
          "description": description,
          "timestamp": timestamp,
          "author": FirebaseAuth.instance.currentUser!.uid,
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("New Note Added!")));
        }
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message!)));
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.title ?? "";
      _descriptionController.text = widget.description ?? "";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Task')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Notes Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Notes Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),

              SizedBox(height: 10),
              ElevatedButton(onPressed: saveNote, child: Text('Add Task')),
            ],
          ),
        ),
      ),
    );
  }
}
