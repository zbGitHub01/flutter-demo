import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 208, 89, 219)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void updateFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var curSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget curPage;

    switch (curSelectedIndex) {
      case 0:
        curPage = GeneratorPage();
        break;
      case 1:
        curPage = FavoritePage();
        break;
      default:
        throw UnimplementedError('No Widget for $curSelectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            /// “SafeArea”小部件用于确保其子小部件位于屏幕的安全区域内，该区域不会被系统栏（例如状态栏、导航栏）或凹口遮挡。
            SafeArea(
                child: NavigationRail(
              extended: constraints.maxWidth >= 500,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                )
              ],
              selectedIndex: curSelectedIndex,
              onDestinationSelected: (value) =>
                  setState(() => curSelectedIndex = value),
            )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: curPage,
            ))
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var curPair = appState.current;

    IconData icon;
    if (appState.favorites.contains(curPair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('点我变幻'),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                  onPressed: () {
                    appState.updateFavorite();
                    print('喜欢的数组是: ${appState.favorites}');
                  },
                  icon: Icon(icon),
                  label: Text('Like'))
            ],
          ),
          SizedBox(height: 20),
          BigCard(curPair: curPair),
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //获取MyAppState实例
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('你当前收藏了${appState.favorites.length}个词组:'),
        ),
        for (var item in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(item.asLowerCase),
          )
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.curPair,
  });

  final WordPair curPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: Color.fromARGB(255, 63, 148, 67),
      elevation: 30,
      // color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Text(
          curPair.asLowerCase,
          style: style,
          semanticsLabel: "${curPair.first} ${curPair.second}",
        ),
      ),
    );
  }
}
