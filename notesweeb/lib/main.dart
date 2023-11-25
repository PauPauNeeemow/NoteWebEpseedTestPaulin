import 'package:flutter/material.dart';

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
  
  int counter = 0;

  void hidePositioned() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(227, 246, 245, 1.0),
      body: Stack(
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
                child: Center(
                  child: Text(
                    'Div 1',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                  ),
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
                            "Bienvenue sur notre plateforme de prise de notes, l'endroit idéal pour capturer, organiser et donner vie à toutes vos idées, pensées et inspirations. Que vous soyez un professionnel cherchant à structurer vos projets ou un créatif désirant garder une trace de ses pensées, vous êtes au bon endroit ! \nIci, vous trouverez un espace accueillant et intuitif pour consigner vos idées, listes, croquis et bien plus encore. Que ce soit sur votre ordinateur, votre tablette ou votre téléphone, notre interface conviviale vous permettra de noter rapidement vos pensées, de les organiser efficacement et de les retrouver facilement quand vous en aurez besoin.",
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
      ),
    );
  }
}