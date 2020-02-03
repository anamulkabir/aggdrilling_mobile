import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aggressive Drilling',
      theme: ThemeData(
        primaryColor: Colors.amber,
      ),
      home: RandomWords(),
    );
  }
}
class RandomWords extends StatefulWidget{
  @override
  RandomWordState createState() => RandomWordState();
}

class RandomWordState extends State<RandomWords>{
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _savedWord = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
//    final randWord = WordPair.random();
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggressive Drilling!'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushedSaved),
          IconButton(icon: Icon(Icons.add),onPressed: _pushedSaved,)
        ],
      ),
      body: buildSuggestions(),
    );
  }
  void _pushedSaved(){
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (BuildContext context){
            final Iterable<ListTile> titles = _savedWord.map(
                (WordPair pair){
                  return ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                    subtitle: Text('Test'),
                  );
                },
            );
            final List<Widget> dividdr = ListTile.divideTiles(
              context: context,
              tiles: titles,
            ).toList();
            return Scaffold(
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: ListView(
                children:dividdr,
              ),
            );
          },
      ),

    );
  }
  Widget buildSuggestions(){
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
        itemBuilder: (context,i) {
        if(i.isOdd){
          return Divider();
        }
        final index = i~/2;
        if(index >= _suggestions.length){
        _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);

    });
  }
  Widget _buildRow(WordPair pair){
    final bool alreadySaved = _savedWord.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: (){
        setState(() {
          if(alreadySaved){
            _savedWord.remove(pair);
          }
          else{
            _savedWord.add(pair);
          }
        });
      },
    );
  }
}