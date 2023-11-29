import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  String title;
  String text;
  double size;
  final Color color;
  Offset position;
  late TextEditingController textEditingController;
  late TextEditingController titleEditingController;

  Note({
    required this.title,
    required this.text,
    required this.size,
    required this.color,
    required this.position,
  }) {
    textEditingController = TextEditingController(text: 'Text');
    titleEditingController = TextEditingController(text: 'Titre : ');
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'size': size,
      'color': color.value,
      'position_dx': position.dx,
      'position_dy': position.dy,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      text: json['text'],
      size: json['size'],
      color: Color(json['color']),
      position: Offset(json['position_dx'], json['position_dy']),
    );
  }
}

class ResponsivePage extends StatefulWidget {
  const ResponsivePage({Key? key}) : super(key: key);

  @override
  _ResponsivePageState createState() => _ResponsivePageState();
}

class _ResponsivePageState extends State<ResponsivePage> {
  bool isVisibleContent = true;
  bool isVisibleButton = false;
  bool isVisibleNotes = false;

  late SharedPreferences prefs;
  late List<Note> notes = [];

  Future<void> loadNotes() async {
    prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList('notes');
    if (savedNotes != null) {
      setState(() {
        notes = savedNotes
            .map((note) => Note.fromJson(json.decode(note)))
            .toList();
      });
    }
  }

  Future<void> saveNotes() async {
    List<String> notesList = notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesList);
  }

  void addNotes() {
    setState(() {
      double size = 200.0;
      Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
      notes.add(Note(title: '', text: '', size: size, color: color, position: Offset.zero));
      saveNotes();
    });
  }

  Widget buildNote(Note note, int index) {
    double touchAreaSize = 15.0;

    return Positioned(
      left: note.position.dx,
      top: note.position.dy,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: note.size,
              height: note.size,
              color: note.color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: note.titleEditingController,
                    onChanged: (value) {
                      setState(() {
                        notes[index].title = value;
                        saveNotes();
                      });
                    },
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: TextField(
                      controller: note.textEditingController,
                      onChanged: (value) {
                        setState(() {
                          notes[index].text = value;
                          saveNotes();
                        });
                      },
                      style: const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1.0),
                        fontFamily: 'Nunito',
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            width: touchAreaSize,
            height: touchAreaSize,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  notes[index].position += details.delta;
                  saveNotes();
                });
              },
              behavior: HitTestBehavior.translucent,
              child: Icon(Icons.open_with),
            ),
          ),
          if (note.position == notes[index].position)
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    notes[index].size += details.delta.dx;
                    saveNotes();
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: touchAreaSize,
                  height: touchAreaSize,
                  color: Colors.transparent,
                  child: Icon(Icons.open_in_full),
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  notes.removeAt(index);
                  saveNotes();
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            bottom: isVisibleButton ? (MediaQuery.of(context).size.height / 2) : -80,
            left: 16,
            child: Visibility(
              visible: isVisibleButton,
              child: Container(
                height: 80,
                width: 150,
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    addNotes();
                  },
                  child: const Text(
                    'Ajouter une note',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1.0), 
                      fontFamily: 'Nunito', 
                      fontSize: 15
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                    padding: EdgeInsets.zero,
                    shape: StadiumBorder(),
                  ),
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            bottom: isVisibleNotes ? 30 : 0,
            left: 190,
            right: 30,
            top: isVisibleNotes ? 30 : MediaQuery.of(context).size.height,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 254, 1.0),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: [
                  ...notes.asMap().entries.map((entry) {
                    return buildNote(entry.value, entry.key);
                  }).toList(),
                ],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            top: isVisibleContent ? MediaQuery.of(context).size.height / 6 : -MediaQuery.of(context).size.height,
            left: MediaQuery.of(context).size.width / 4,
            right: MediaQuery.of(context).size.width / 4,
            bottom: isVisibleContent ? MediaQuery.of(context).size.height / 6 : MediaQuery.of(context).size.height * 1.2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isVisibleContent = !isVisibleContent;
                  isVisibleButton = true;
                  isVisibleNotes = true;
                });
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 254, 1.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        child: Image.asset(
                          'assets/images/AccueilImage1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Text(
                        "Bienvenue sur ma plateforme de prise de notes, l'endroit idéal pour capturer, organiser et donner vie à toutes vos idées, pensées et inspirations. Que vous soyez un professionnel cherchant à structurer vos projets ou un créatif désirant garder une trace de ses pensées, vous êtes au bon endroit ! \nIci, vous trouverez un espace accueillant et intuitif pour consigner vos idées, listes, croquis et bien plus encore. Que ce soit sur votre ordinateur, votre tablette ou votre téléphone, notre interface conviviale vous permettra de noter rapidement vos pensées, de les organiser efficacement et de les retrouver facilement quand vous en aurez besoin.",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontFamily: 'Nunito',
                          color: Color.fromRGBO(30, 30, 30, 1.0),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isVisibleContent = !isVisibleContent;
                            isVisibleButton = true;
                            isVisibleNotes = true;
                          });
                        },
                        child: Text(
                          "Commençons !!!",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1.0),
                            fontFamily: 'Nunito',
                            fontSize: MediaQuery.of(context).size.width / 100,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                          minimumSize: Size(91, 26),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

            
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  void dispose() {
    saveNotes();
    super.dispose();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: const ResponsivePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}