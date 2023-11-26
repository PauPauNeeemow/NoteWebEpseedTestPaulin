import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:notesweeb/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoNotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ToDoNotes Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isVisible = true;

  List<Note> notes = [];

  RandomColor _randomColor = RandomColor();
  
  int counter = 0;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesStringList = prefs.getStringList('notes');

    if (notesStringList != null) {
      setState(() {
        notes = notesStringList
            .map((noteString) => Note.fromMap(Map<String, dynamic>.from(jsonDecode(noteString))))
            .toList();
      });
    }
  }

  void saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesStringList =
        notes.map((note) => jsonEncode(note.toMap())).toList();

    await prefs.setStringList('notes', notesStringList);
  }

  void addNoteAtPosition(double x, double y) {
    setState(() {
      notes.add(Note(
        x: x,
        y: y,
        content: 'New note',
      ));
    });
    saveNotes();
  }

  void moveNote(int index, double dx, double dy) {
    setState(() {
      notes[index].x += dx;
      notes[index].y += dy;
    });
    saveNotes();
  }

  void deleteNoteAt(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void hidePositioned() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(227, 246, 245, 1.0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return _buildMobileLayout();
          } else if (constraints.maxWidth < 1450){
            return _buildTabletLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        Positioned(
          bottom: 85,
          left: 80,
          right: 80,
          top: 85,
          child: Visibility(
            visible: true,
            child: Container(
              height: 851,
              width: 1164,
              color: Color.fromRGBO(255, 255, 254, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 851,
                        width: 316,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              hidePositioned();
                            },
                            child: Text(
                              'Get Started',
                              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                              minimumSize: Size(91, 26),
                              maximumSize: Size(91, 26),
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 851,
                        width: 786,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            for (int i = 0; i < notes.length; i++)
                              Positioned(
                                left: notes[i].x,
                                top: notes[i].y,
                                child: Draggable(
                                  childWhenDragging: Container(),
                                  feedback: Container(
                                    height: 150,
                                    width: 125,
                                    color: _randomColor.randomColor(),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(8),
                                        hintText: notes[i].content,
                                      ),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  child: Container(
                                    height: 150,
                                    width: 125,
                                    margin: EdgeInsets.only(bottom: 8),
                                    color: _randomColor.randomColor(),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(8),
                                        hintText: notes[i].content,
                                      ),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  onDraggableCanceled: (_, offset) {
                                    moveNote(i, offset.dx, offset.dy);
                                  },
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        top: isVisible ? 0 : -MediaQuery.of(context).size.height,
        left: 0,
        child: Visibility(
          visible: isVisible,
          child: GestureDetector(
            onTap: () {
              hidePositioned();
            },
            child: Container(
              height: 390,
              width: 239,
              color: Color.fromRGBO(255, 255, 254, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/AccueilImage1.png',
                      width: 239,
                      height: 108,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Bienvenue sur ma plateforme de prise de notes, l'endroit idéal pour capturer, organiser et donner vie à toutes vos idées, pensées et inspirations. Que vous soyez un professionnel cherchant à structurer vos projets ou un créatif désirant garder une trace de ses pensées, vous êtes au bon endroit ! \nIci, vous trouverez un espace accueillant et intuitif pour consigner vos idées, listes, croquis et bien plus encore. Que ce soit sur votre ordinateur, votre tablette ou votre téléphone, notre interface conviviale vous permettra de noter rapidement vos pensées, de les organiser efficacement et de les retrouver facilement quand vous en aurez besoin.",
                          style: TextStyle(
                            fontSize: 6.5,
                            fontFamily: 'Nunito',
                            color: Color.fromRGBO(30, 30, 30, 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          hidePositioned();
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 10),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                          minimumSize: Size(91, 26),
                          maximumSize: Size(91, 26),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Stack(
      children: [
        Positioned(
          bottom: 85,
          left: 80,
          right: 80,
          top: 85,
          child: Visibility(
            visible: true,
            child: Container(
              height: 851,
              width: 1164,
              color: Color.fromRGBO(255, 255, 254, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 851,
                        width: 316,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 100),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Div 1',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                        ),
                      ),
                      Container(
                        height: 851,
                        width: 786,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        child: Column(
                          children: List.generate(
                            2,
                            (index) => Container(
                              height: 150,
                              width: 125,
                              margin: EdgeInsets.only(bottom: 8),
                              color: _randomColor.randomColor(),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  hintText: 'Write here...',
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        top: isVisible ? 0 : -MediaQuery.of(context).size.height,
        left: 0,
        child: Visibility(
          visible: isVisible,
          child: GestureDetector(
            onTap: () {
              hidePositioned();
            },
            child: Container(
              height: 390,
              width: 239,
              color: Color.fromRGBO(255, 255, 254, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/AccueilImage1.png',
                      width: 239,
                      height: 108,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Bienvenue sur ma plateforme de prise de notes, l'endroit idéal pour capturer, organiser et donner vie à toutes vos idées, pensées et inspirations. Que vous soyez un professionnel cherchant à structurer vos projets ou un créatif désirant garder une trace de ses pensées, vous êtes au bon endroit ! \nIci, vous trouverez un espace accueillant et intuitif pour consigner vos idées, listes, croquis et bien plus encore. Que ce soit sur votre ordinateur, votre tablette ou votre téléphone, notre interface conviviale vous permettra de noter rapidement vos pensées, de les organiser efficacement et de les retrouver facilement quand vous en aurez besoin.",
                          style: TextStyle(
                            fontSize: 6.5,
                            fontFamily: 'Nunito',
                            color: Color.fromRGBO(30, 30, 30, 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          hidePositioned();
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 10),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                          minimumSize: Size(91, 26),
                          maximumSize: Size(91, 26),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 29,
          right: MediaQuery.of(context).size.width / 2.5,
          child: Visibility(
            visible: true,
            child: Container(
              height: 369,
              width: 182,
              color: Color.fromRGBO(255, 255, 254, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 2,
                          left: 2,
                        ),
                        child: Container(
                          height: 50,
                          width: 78,
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              addNoteAtPosition(5,5);
                            },
                            child: Text(
                              'Add notes',
                              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontFamily: 'Nunito', fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                              padding: EdgeInsets.zero,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 360,
                        width: 91,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: List.generate(
                            notes.length,
                            (index) => Container(
                              height: 100,
                              width: 75,
                              margin: EdgeInsets.only(bottom: 5),
                              color: _randomColor.randomColor(),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8),
                                  hintText: 'Write here...',
                                ),
                                style: TextStyle(fontSize: 10),
                                controller: TextEditingController(text: notes[index].content),
                                onChanged: (text) {
                                  setState(() {
                                    notes[index].content = text;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        top: isVisible ? 0 : -MediaQuery.of(context).size.height,
        left: MediaQuery.of(context).size.width / 2.5,
        right: 45,
        child: Visibility(
          visible: isVisible,
          child: GestureDetector(
            onTap: () {
              hidePositioned();
            },
            child: Container(
              height: 317,
              width: 143,
              color: Color.fromRGBO(255, 255, 254, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/AccueilImage1.png',
                      width: 143,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Bienvenue sur ma plateforme de prise de notes, l'endroit idéal pour capturer, organiser et donner vie à toutes vos idées, pensées et inspirations. Que vous soyez un professionnel cherchant à structurer vos projets ou un créatif désirant garder une trace de ses pensées, vous êtes au bon endroit ! \nIci, vous trouverez un espace accueillant et intuitif pour consigner vos idées, listes, croquis et bien plus encore. Que ce soit sur votre ordinateur, votre tablette ou votre téléphone, notre interface conviviale vous permettra de noter rapidement vos pensées, de les organiser efficacement et de les retrouver facilement quand vous en aurez besoin.",
                          style: TextStyle(
                            fontSize: 6.5,
                            fontFamily: 'Nunito',
                            color: Color.fromRGBO(30, 30, 30, 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          hidePositioned();
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 10),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 210, 82, 1.0),
                          minimumSize: Size(91, 26),
                          maximumSize: Size(91, 26),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}