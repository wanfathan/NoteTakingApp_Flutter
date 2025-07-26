import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Required to run async code before app starts
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter
  await Hive.initFlutter();

  // Open a box (like a table in database) to store notes
  await Hive.openBox('notesBox');

  // Run the app
  runApp(MyApp());
}

// The root widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       theme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E), // Dark grey
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 192, 173, 2), // Yellow AppBar
      foregroundColor: Colors.black,  // Text/Icon color on AppBar
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Default text color
      bodyMedium: TextStyle(color: Colors.white),
    ),
    cardColor: Color(0xFF2E2E2E), // Dark card background
  ),

  home: NotesPage(),
);
  }
}

// The main screen for the app
class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final Box notesBox = Hive.box('notesBox'); // Reference to the notesBox
  final TextEditingController noteController = TextEditingController(); // To read input

  // Function to add a new note
  void addNote() {
    final text = noteController.text.trim(); // Get and trim the input
    if (text.isNotEmpty) {
      notesBox.add(text); // Save the note to Hive
      noteController.clear(); // Clear the input field
    }
  }

  void showEditDialog(int index, String currentNote) {
  TextEditingController editController = TextEditingController(text: currentNote);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit Note"),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Edit your note",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                notesBox.putAt(index, updatedText); // 🔄 Update note in Hive
              }
              Navigator.pop(context); // Close dialog
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mnemosynes Labyrinth by Aan"),
      centerTitle: true),

      body: Column(
        children: [
          // Input field and button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Note input field
                Expanded(
                  child: TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: "Type your note...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Add button
                ElevatedButton(
                  onPressed: addNote,
                  child: Text("Add"),
                ),
              ],
            ),
          ),

      
      // This will listen to the notesBox and update UI automatically
      Expanded(
  child: ValueListenableBuilder(
    valueListenable: notesBox.listenable(),
    builder: (context, box, _) {
      if (box.isEmpty) {
        return Center(child: Text("No notes yet"));
      }

      return ListView.builder(
        itemCount: box.length,
        itemBuilder: (context, index) {
          final note = box.getAt(index); // ✅ make sure this is here

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color.fromARGB(255, 42, 52, 51),
            child: InkWell(
              onTap: () => showEditDialog(index, note),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        note.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                          )
,
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => notesBox.deleteAt(index),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ),
)

        ],
      ),
    );
  }
}
