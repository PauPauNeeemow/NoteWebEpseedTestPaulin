import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class ResizableNote extends StatefulWidget {
  final Note note;

  const ResizableNote({Key? key, required this.note}) : super(key: key);

  @override
  _ResizableNoteState createState() => _ResizableNoteState();
}

class _ResizableNoteState extends State<ResizableNote> {
  Offset position = Offset(20, 20);
  double _width = 150;
  double _height = 100;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );
          });
        },
        child: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              _width = 150 * details.scale;
              _height = 100 * details.scale;
            });
          },
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: widget.note.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(widget.note.text),
            ),
          ),
        ),
      ),
    );
  }
}

class Offset {
  final double dx;
  final double dy;

  Offset(this.dx, this.dy);

  Map<String, dynamic> toJson() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }
}

class OffsetSerializer {
  static Map<String, dynamic> toJson(Offset offset) {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
    };
  }

  static Offset fromJson(Map<String, dynamic> json) {
    return Offset(json['dx'] ?? 0.0, json['dy'] ?? 0.0);
  }
}

class Note {
  String id;
  Offset position;
  late Color backgroundColor;
  late String text;

  Note({required this.id, required this.position, required this.text}) {
    backgroundColor = _randomColor();
  }

  Color _randomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': OffsetSerializer.toJson(position),
      'backgroundColor': backgroundColor.toString(),
      'text': text,
    };
  }

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        position = Offset(json['position']['dx'], json['position']['dy']),
        backgroundColor = Color(json['backgroundColor']),
        text = json['text'];
}

class _MyHomePageState extends State<MyHomePage> {
  bool isVisible = true;
  bool isVisible2 = false;
  bool premiereColonneRemplie = false;

  List<Note> notes = [];
  TextEditingController noteController = TextEditingController();
  
  int counter = 0;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? notesStringList = prefs.getStringList('notes');

    if (notesStringList != null) {
      setState(() {
        notes = notesStringList.map((noteString) {
          Map<String, dynamic> noteMap = jsonDecode(noteString);
          return Note.fromJson(noteMap);
        }).toList();
      });
    }
  }

  void saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> notesStringList = notes.map((note) {
      return jsonEncode(note.toJson());
    }).toList();

    prefs.setStringList('notes', notesStringList);
  }

  void hidePositioned() {
    setState(() {
      isVisible = false;
      isVisible2 = true;
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
    double screenWidth = MediaQuery.of(context).size.width;

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 2,
                          left: 2,
                        ),
                        child: Container(
                          height: 80,
                          width: 150,
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                notes.add(
                                  Note(
                                    id: 'Nouvelle note',
                                    position: Offset(5.5, 5.5),
                                    text: 'Contenu de la note'
                                  )
                                );
                                saveNotes();    
                              });
                            },
                            child: Text(
                              'Ajouter une note',
                              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontFamily: 'Nunito', fontSize: 15),
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
                        height: 800,
                        width: 1400,
                        padding: EdgeInsets.all(8),
                        child: ReorderableListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            Note note = notes[index];
                            TextEditingController noteController = TextEditingController(text: note.id);

                            return Draggable(
                              key: Key('$index'),
                              child: Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: note.backgroundColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: noteController,
                                          onChanged: (value) {
                                            setState(() {
                                              note.id = value;
                                              saveNotes();
                                            });
                                          },
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                          maxLines: null,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Ecrire ici...',
                                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                        child: IconButton(
                                          icon: Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              notes.removeAt(index);
                                              saveNotes();
                                            });
                                          },
                                        ),
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(Icons.drag_handle, size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              feedback: Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: note.backgroundColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Text(note.id),
                                ),
                              ),
                              onDraggableCanceled: (velocity, offset) {
                                // Mettez à jour la position de la note ici si nécessaire
                              },
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = notes.removeAt(oldIndex);
                              notes.insert(newIndex, item);
                              saveNotes();
                            });
                          },
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
              height: screenWidth > 500 ? 709 : 100,
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
                            fontSize: 8.5,
                            fontFamily: 'Nunito',
                            color: Color.fromRGBO(30, 30, 30, 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          hidePositioned();
                        },
                        child: Text(
                          'Commençons !!!',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 15),
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
        for (final note in notes)
        ResizableNote(note: note),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 2,
                          left: 2,
                        ),
                        child: Container(
                          height: 80,
                          width: 150,
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                notes.add(
                                  Note(
                                    id: 'Nouvelle note',
                                    position: Offset(5.5, 5.5),
                                    text: 'Contenu de la note'));
                                saveNotes();
                              });
                            },
                            child: Text(
                              'Ajouter une note',
                              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontFamily: 'Nunito', fontSize: 15),
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
                        height: 851,
                        width: 1000,
                        padding: EdgeInsets.all(8),
                        child: ReorderableListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            Note note = notes[index];
                            TextEditingController noteController = TextEditingController(text: note.id);

                            return Container(
                              key: Key('$index'),
                              decoration: BoxDecoration(
                                color: note.backgroundColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: noteController,
                                      onChanged: (value) {
                                        setState(() {
                                          note.id = value;
                                          saveNotes();
                                        });
                                      },
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                      maxLines: null,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Ecrire ici...',
                                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          notes.removeAt(index);
                                          saveNotes();
                                        });
                                      },
                                    ),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(Icons.drag_handle_rounded),
                                  ),
                                ],
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = notes.removeAt(oldIndex);
                              notes.insert(newIndex, item);
                              saveNotes();
                            });
                          },
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
                            fontSize: 8.5,
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
                          "Commençons !!!",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0),fontFamily: 'Nunito',fontSize: 15),
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
            visible: isVisible,
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
                          width: 100,
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                notes.add(
                                  Note(
                                    id: 'Nouvelle note',
                                    position: Offset(5.5, 5.5),
                                    text: 'Contenu de la note'));
                                saveNotes();
                              });
                            },
                            child: Text(
                              'Ajouter une note',
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
                        child: ReorderableListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            Note note = notes[index];
                            TextEditingController noteController = TextEditingController(text: note.id);

                            return Container(
                              key: Key('$index'),
                              decoration: BoxDecoration(
                                color: note.backgroundColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: noteController,
                                      onChanged: (value) {
                                        setState(() {
                                          note.id = value;
                                          saveNotes();
                                        });
                                      },
                                      style: TextStyle(
                                        fontSize: 5,
                                        color: Colors.black,
                                      ),
                                      maxLines: null,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Ecrire ici...',
                                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 10),
                                      onPressed: () {
                                        setState(() {
                                          notes.removeAt(index);
                                          saveNotes();
                                        });
                                      },
                                    ),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(Icons.drag_handle_rounded),
                                  ),
                                ],
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = notes.removeAt(oldIndex);
                              notes.insert(newIndex, item);
                              saveNotes();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          top: 10,
          child: Visibility(
            visible: isVisible2,
            child: Container(
              height: 369,
              width: 661,
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
                          width: 80,
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                notes.add(
                                  Note(
                                    id: 'Nouvelle note',
                                    position: Offset(5.5, 5.5),
                                    text: 'Contenu de la note'));
                                saveNotes(); // Enregistrer la note ajoutée
                              });
                            },
                            child: Text(
                              'Ajouter une note',
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
                        width: 270,
                        padding: EdgeInsets.all(8),
                        child: ReorderableListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            Note note = notes[index];
                            TextEditingController noteController = TextEditingController(text: note.id);

                            return Container(
                              key: Key('$index'),
                              decoration: BoxDecoration(
                                color: note.backgroundColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: noteController,
                                      onChanged: (value) {
                                        setState(() {
                                          note.id = value;
                                          saveNotes();
                                        });
                                      },
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      maxLines: null,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Ecrire ici...',
                                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          notes.removeAt(index);
                                          saveNotes();
                                        });
                                      },
                                    ),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(Icons.drag_handle_rounded),
                                  ),
                                ],
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = notes.removeAt(oldIndex);
                              notes.insert(newIndex, item);
                              saveNotes();
                            });
                          },
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
                          'Commençons !!!',
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

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}