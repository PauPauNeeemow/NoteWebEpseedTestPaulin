import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class Note {
  final String id;
  Offset position;
  Color backgroundColor;

  Note({required this.id, required this.position, required this.backgroundColor});
}

class _MyHomePageState extends State<MyHomePage> {
  bool isVisible = true;
  bool isVisible2 = false;
  bool premiereColonneRemplie = false;

  List<String> notes = [];
  TextEditingController noteController = TextEditingController();

  RandomColor _randomColor = RandomColor();
  
  int counter = 0;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('notes') ?? [];
    });
  }

  void saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', notes);
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
                                notes.add('Nouvelle note');
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
                        height: 360,
                        width: 1400,
                        padding: EdgeInsets.all(8),
                        child: ReorderableListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            TextEditingController noteController = TextEditingController(text: notes[index]);

                            return Container(
                              key: Key('$index'),
                              decoration: BoxDecoration(
                                color: _randomColor.randomColor(),
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
                                        notes[index] = value;
                                        saveNotes();
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
                                notes.add('Nouvelle note');
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
                        child: ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            TextEditingController noteController = TextEditingController(text: notes[index]);

                            return Container(
                              decoration: BoxDecoration(
                                color: _randomColor.randomColor(),
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
                                        notes[index] = value;
                                        saveNotes();
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
                                    child: Icon(Icons.drag_handle),
                                  ),
                                ],
                              ),
                            );
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
                                notes.add('Nouvelle note');
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
                        child: ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            TextEditingController noteController = TextEditingController(text: notes[index]);

                            return Container(
                              decoration: BoxDecoration(
                                color: _randomColor.randomColor(),
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
                                        notes[index] = value;
                                        saveNotes();
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
                                ],
                              ),
                            );
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
                                notes.add('Nouvelle note');
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
                        child: ReorderableListView(
                          padding: EdgeInsets.zero,
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
                          children: notes.asMap().entries.map((entry) {
                            int index = entry.key;
                            String note = entry.value;
                            TextEditingController noteController = TextEditingController(text: note);

                            return Container(
                              key: Key('$index'),
                              decoration: BoxDecoration(
                                color: _randomColor.randomColor(),
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
                                        notes[index] = value;
                                        saveNotes();
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
                                        contentPadding: EdgeInsets.zero,
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
                                    child: Icon(Icons.drag_handle),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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