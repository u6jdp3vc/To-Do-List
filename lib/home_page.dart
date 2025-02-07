/*// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Note> _notes = [];
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  int? noteKey;
  int? noteIndex;
  String? noteName;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    List<Note> notes = await dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  /*void _addNote() async {
    Note newNote = Note(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    int id = await dbHelper.insert(newNote);
    setState(() {
      newNote.id = id;
      _notes.add(newNote);
    });
    clearFields();
  }*/

  void _addNote() async {
    Note newNote = Note(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    int id = await dbHelper.insert(newNote);
    setState(() {
      newNote.id = id;
      _notes.add(newNote);
    });
    clearFields();

    // Schedule deletion after 1 minute
    Timer(Duration(minutes: 1), () async {
      await dbHelper.delete(id);
      setState(() {
        _notes.remove(newNote);
      });
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateNote(int index, int key) async {
    Note updatedNote = Note(
      id: key,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    await dbHelper.update(updatedNote);
    setState(() {
      _notes[index] = updatedNote;
    });
    clearFields();
  }

  void _deleteNote(int index, int key) async {
    await dbHelper.delete(key);
    setState(() {
      _notes.removeAt(index);
    });
  }

  Future<bool> _checkDuplication(String text) async {
    return await dbHelper.checkDuplication(text);
  }

  void _searchByName() async {
    List<Note> searchResults =
        await dbHelper.searchByName(searchController.text.trim());
    setState(() {
      _notes = searchResults;
    });
  }

  Future<void> _deleteAllNotes() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete all notes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await dbHelper.deleteAllNotes();
      _loadNotes();
      clearFields();
      showSnackbar('All notes deleted successfully.');
    }
  }

  void clearFields() {
    nameController.clear();
    descriptionController.clear();
    searchController.clear();
    noteIndex = null;
    noteKey = null;
    noteName = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'CP213 - Mobile Programming Project',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: nameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Name",
                          hintText: "Enter note name.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some name.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        autofocus: false,
                        maxLines: 5,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Description",
                          hintText: "Enter some note description.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some description.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (noteIndex == null || noteKey == null) {
                                    showSnackbar(
                                        'To perform the update operation, please select a note first.');
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    if (noteName != nameController.text) {
                                      bool isDuplicate =
                                          await _checkDuplication(
                                              nameController.text.trim());
                                      if (!isDuplicate) {
                                        _updateNote(noteIndex!, noteKey!);
                                        showSnackbar(
                                            'Note updated successfully.');
                                      } else {
                                        showSnackbar(
                                            'Please try another note name to avoid duplication.');
                                      }
                                    } else {
                                      _updateNote(noteIndex!, noteKey!);
                                      showSnackbar(
                                          'Note updated successfully.');
                                    }
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                _deleteAllNotes();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Delete All Notes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: TextFormField(
                  controller: searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Search",
                    suffixIcon: const Icon(Icons.search, color: Colors.blue),
                    hintText: "Search note by name",
                    floatingLabelStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1),
                    ),
                  ),
                  onChanged: (_) {
                    _searchByName();
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index].name),
                    subtitle: Text(_notes[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            nameController.text = _notes[index].name;
                            descriptionController.text =
                                _notes[index].description;
                            noteIndex = index;
                            noteKey = _notes[index].id;
                            noteName = _notes[index].name;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteNote(index, _notes[index].id!);
                            showSnackbar('Note deleted successfully.');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              bool isDuplicate =
                  await _checkDuplication(nameController.text.trim());
              if (!isDuplicate) {
                _addNote();
                showSnackbar('Note added successfully.');
              } else {
                showSnackbar(
                    'Please try another note name to avoid duplication.');
              }
              FocusScope.of(context).unfocus();
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}*/

// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Note> _notes = [];
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  int noteKey = 0;
  int noteIndex = 0;
  String? noteName;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    List<Note> notes = await dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addNote() async {
    print('Adding new note...');
    Note newNote = Note(
      id: noteKey,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );

    int id = await DatabaseHelper.instance.insert(newNote);
    setState(() {
      newNote.id = id;
      _notes.add(newNote);
    });
    clearFields();

    Timer(Duration(seconds: 30), () async {
      await dbHelper.delete(id);
      setState(() {
        _notes.remove(newNote);
      });
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateNote(int index, int key) async {
    Note updatedNote = Note(
      id: key,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    await dbHelper.update(updatedNote);
    setState(() {
      _notes[index] = updatedNote;
      noteKey = key; // Assuming noteKey needs to be updated here
    });
    clearFields();

    Timer(Duration(seconds: 30), () async {
      await dbHelper.delete(key); // Use key instead of id
      setState(() {
        _notes.remove(updatedNote); // Remove updatedNote instead of newNote
      });
    });
  }

  void _deleteNote(int index, int key) async {
    await dbHelper.delete(key);
    setState(() {
      _notes.removeAt(index);
    });
  }

  Future<bool> _checkDuplication(String text) async {
    return await dbHelper.checkDuplication(text);
  }

  void _searchByName() async {
    List<Note> searchResults =
        await dbHelper.searchByName(searchController.text.trim());
    setState(() {
      _notes = searchResults;
    });
  }

  Future<void> _deleteAllNotes() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete all notes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await dbHelper.deleteAllNotes();
      _loadNotes();
      clearFields();
      showSnackbar('All notes deleted successfully.');
    }
  }

  void clearFields() {
    nameController.clear();
    descriptionController.clear();
    searchController.clear();
    noteName = null;
    startTimeController.clear(); // เพิ่มให้ล้าง startTimeController
    endTimeController.clear(); // เพิ่มให้ล้าง endTimeController
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'To-Do List App',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: nameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Name",
                          hintText: "Enter note name.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some name.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: startTimeController,
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          hintText: 'Enter start time',
                        ),
                        onTap: () async {
                          TimeOfDay? startTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (startTime != null) {
                            startTimeController.text =
                                startTime.format(context);
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter start time';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: endTimeController,
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          hintText: 'Enter end time',
                        ),
                        onTap: () async {
                          TimeOfDay? endTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (endTime != null) {
                            endTimeController.text = endTime.format(context);
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter end time';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        autofocus: false,
                        maxLines: 5,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Description",
                          hintText: "Enter some note description.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some description.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (noteName != nameController.text) {
                                    bool isDuplicate = await _checkDuplication(
                                        nameController.text.trim());
                                    if (!isDuplicate) {
                                      _updateNote(noteIndex, noteKey);
                                      showSnackbar(
                                          'Note updated successfully.');
                                    } else {
                                      showSnackbar(
                                          'Please try another note name to avoid duplication.');
                                    }
                                  } else {
                                    _updateNote(noteIndex, noteKey);
                                    showSnackbar('Note updated successfully.');
                                  }
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                _deleteAllNotes();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Delete All Notes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: TextFormField(
                  controller: searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Search",
                    suffixIcon: const Icon(Icons.search, color: Colors.blue),
                    hintText: "Search note by name",
                    floatingLabelStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1),
                    ),
                  ),
                  onChanged: (_) {
                    _searchByName();
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index].name),
                    subtitle: Text(_notes[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            nameController.text = _notes[index].name;
                            descriptionController.text =
                                _notes[index].description;
                            noteIndex = index;
                            noteKey = _notes[index].id!;
                            noteName = _notes[index].name;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showSnackbar('Note deleted successfully.');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              bool isDuplicate =
                  await _checkDuplication(nameController.text.trim());
              if (!isDuplicate) {
                _addNote(); // เรียกใช้ _addNote โดยไม่มีอาร์กิวเมนต์
                showSnackbar('Note added successfully.');
              } else {
                showSnackbar(
                    'Please try another note name to avoid duplication.');
              }
              FocusScope.of(context).unfocus();
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
