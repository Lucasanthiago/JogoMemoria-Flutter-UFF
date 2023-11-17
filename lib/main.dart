import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MemoryGameApp());

class MemoryGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Memória EAFC 2024',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MemoryGameHomePage(),
    );
  }
}

class MemoryGameHomePage extends StatefulWidget {
  @override
  _MemoryGameHomePageState createState() => _MemoryGameHomePageState();
}

class _MemoryGameHomePageState extends State<MemoryGameHomePage> {
  String playerName = "";
  bool useNumbers = false;
  bool useImages = false;
  List<Item> items = [];
  Item? firstSelected;
  Item? secondSelected;
  int tries = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jogo da Memória EAFC 2024')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => playerName = value),
                decoration: InputDecoration(labelText: 'Apelido do jogador'),
              ),
              Row(
                children: [
                  Checkbox(
                      value: useImages,
                      onChanged: (value) => setState(() => useImages = value!)),
                  Text('Imagens'),
                ],
              ),
              ElevatedButton(
                onPressed: startGame,
                child: Text('Iniciar Jogo'),
              ),
              GridView.builder(
                padding: const EdgeInsets.all(4.0),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8),
                itemCount: items.length,
                itemBuilder: (context, index) => buildItem(index),
              ),
              if (items.every((item) => item.isMatched))
                Column(
                  children: [
                    Text('Jogo completo com $tries tentativas!'),
                    ElevatedButton(
                        onPressed: resetGame, child: Text('Reiniciar Jogo')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    final item = items[index];
    return GestureDetector(
      onTap: () => selectItem(item),
      child: Container(
        width: 60,
        height: 60,
        margin: EdgeInsets.all(4),
        color: item.isMatched ? Colors.white : Colors.grey,
        child: Center(
          child: item.isVisible
              ? (item.isImage
                  ? Image.asset('images/${item.value}.png')
                  : Text(item.value.toString()))
              : null,
        ),
      ),
    );
  }

  void startGame() {
    final images = List.generate(10, (index) => 'image$index');
    final numbers = List.generate(10, (index) => index);
    final selectedItems = [];

    if (useNumbers) selectedItems.addAll(numbers);
    if (useImages) selectedItems.addAll(images);

    final randomizedItems = selectedItems..shuffle(Random());
    final gameItems = randomizedItems.take(10).toList()
      ..addAll(randomizedItems.take(10));
    gameItems.shuffle(Random());

    setState(() {
      items = gameItems
          .map((value) => Item(value: value, isImage: images.contains(value)))
          .toList();
      tries = 0;
    });
  }

  void selectItem(Item item) {
    if (firstSelected == null) {
      setState(() {
        firstSelected = item..isVisible = true;
      });
    } else if (secondSelected == null && item != firstSelected) {
      setState(() {
        secondSelected = item..isVisible = true;
      });

      if (firstSelected!.value == secondSelected!.value) {
        setState(() {
          firstSelected!.isMatched = true;
          secondSelected!.isMatched = true;
          firstSelected = null;
          secondSelected = null;
          tries++;
        });
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            firstSelected!.isVisible = false;
            secondSelected!.isVisible = false;
            firstSelected = null;
            secondSelected = null;
            tries++;
          });
        });
      }
    }
  }

  void resetGame() {
    setState(() {
      items = [];
      firstSelected = null;
      secondSelected = null;
      tries = 0;
    });
  }
}

class Item {
  final dynamic value;
  final bool isImage;
  bool isVisible = false;
  bool isMatched = false;

  Item({required this.value, this.isImage = false});
}
