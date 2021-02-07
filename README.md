# Menu Side Animation

### SideMenuAnimation and SideMenuAnimationBuilder

<TABLE BORDER>
    <TR>
        <TH style="text-align:center">SIDE MENU</TH>
        <TH style="text-align:center">SIDE MENU BUILDER</TH>
    </TR>
	<TR>
		<TD><img src="./art/side-menu.gif" alt="Side-Menu" width="200"/></TD> 
		<TD><img src="./art/side-menu-builder.gif" alt="Side-Menu-builder" width="200"/></TD> 
	</TR>
</TABLE>

## Features
- SideMenu
- SideMenuBuilder
- Optional parameter tap out side to dismiss
- Optional parameter scrim color
- Custom color item side menu selected
- Custom color item side menu unselected
- Custom width side menu
- Custom duration of the animation side menu
## Getting Started

You should ensure that you add the router as a dependency in your flutter project.

```yaml
dependencies:
 side_menu_animation: "^0.0.1"
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is a example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Usage

Need to include the import the package to the dart file where it will be used, use the below command,

```dart
import 'package:side_menu_animation/side_menu_animation.dart';
```

### Model And Data

```dart
class MenuValues {
  const MenuValues({this.title, this.icon, this.items, this.color});
  final String title;
  final IconData icon;
  final Color color;
  final List<MenuValues> items;
}

const myMenuValue = const [
  MenuValues(icon: Icons.close),
  MenuValues(
    icon: Icons.music_note_rounded,
    title: 'Music',
    items: const [
      MenuValues(icon: Icons.music_note, title: 'Songs', color: Color(0xFF5863F8)),
      MenuValues(icon: Icons.play_arrow, title: 'Now Playing', color: Color(0xFFFF3366)),
      MenuValues(icon: Icons.album, title: 'Albums', color: Color(0xFFFFE433)),
    ],
  ),
  MenuValues(
    icon: Icons.phone_bluetooth_speaker_rounded,
    title: 'Calls',
    items: const [
      MenuValues(icon: Icons.phone_callback_rounded, title: 'Incoming', color: Color(0xFF2CDA9D)),
      MenuValues(icon: Icons.phone_missed_rounded, title: 'Missing', color: Color(0xFF7678ED)),
      MenuValues(icon: Icons.phone_disabled_rounded, title: 'Outgoing ', color: Color(0xFF446DF6)),
    ],
  ),
  MenuValues(
    icon: Icons.cloud,
    title: 'Cloud',
    items: const [
      MenuValues(icon: Icons.download_rounded, title: 'Downloading', color: Color(0xFFFF4669)),
      MenuValues(icon: Icons.upload_file, title: 'Done', color: Color(0xFFFF69EB)),
      MenuValues(icon: Icons.cloud_upload, title: 'Upload', color: Color(0xFF2CDA9D)),
    ],
  ),
  MenuValues(
    icon: Icons.wifi,
    title: 'Wifi',
    items: const [
      MenuValues(icon: Icons.wifi_off_rounded, title: 'Off', color: Color(0xFF5AD2F4)),
      MenuValues(icon: Icons.signal_wifi_4_bar_lock_sharp, title: 'Lock', color: Color(0xFFFF3366)),
      MenuValues(icon: Icons.perm_scan_wifi_rounded, title: 'Limit', color: Color(0xFFFFC07F)),
    ],
  ),
  MenuValues(
    icon: Icons.favorite,
    title: 'Favorites',
    items: const [
      MenuValues(icon: Icons.favorite, title: 'Favorite', color: Color(0xFF5863F8)),
      MenuValues(icon: Icons.favorite_border, title: 'Not Favorite', color: Color(0xFFF7C548)),
      MenuValues(icon: Icons.volunteer_activism, title: 'Activism', color: Color(0xFF00A878)),
    ],
  ),
  MenuValues(
    icon: Icons.network_cell,
    title: 'Networks',
    items: const [
      MenuValues(icon: Icons.wifi, title: 'Wifi', color: Color(0xFF96858F)),
      MenuValues(icon: Icons.network_cell, title: 'Network', color: Color(0xFF6D7993)),
      MenuValues(icon: Icons.bluetooth, title: 'Bluetooth', color: Color(0xFF9099A2)),
    ],
  ),
];
```

## Widget Screen

```dart
class Screen extends StatelessWidget {
  const Screen({Key key, @required this.itemsScreen}) : super(key: key);

  final List<MenuValues> itemsScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemsScreen.length,
        (index) => Expanded(
          child: Container(
            color: itemsScreen[index].color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(itemsScreen[index].icon, size: 75, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  itemsScreen[index].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## SideMenu

```dart
class SideMenuScreen extends StatelessWidget {
  final _index = ValueNotifier<int>(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideMenuAnimation(
        appBarBuilder: (showMenu) => AppBar(
          leading: IconButton(icon: Icon(Icons.menu, color: Colors.black), onPressed: showMenu),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          title: ValueListenableBuilder<int>(
            valueListenable: _index,
            builder: (_, value, __) => Text(myMenuValue[value].title, style: TextStyle(color: Colors.black)),
          ),
        ),
        views: List.generate(
          myMenuValue.length - 1,
          (index) => Screen(itemsScreen: myMenuValue[index + 1].items),
        ),
        items: myMenuValue.map((value) => Icon(value.icon, color: Colors.white, size: 50)).toList(),
        selectedColor: Color(0xFFFF595E),
        unselectedColor: Color(0xFF1F2041),
        tapOutsideToDismiss: true,
        scrimColor: Colors.black45,
        onItemSelected: (value) {
          if (value > 0 && value != _index.value) _index.value = value;
        },
      ),
    );
  }
}
```

## SideMenuBuilder

```dart
class SideMenuBuilderScreen extends StatelessWidget {
  final _index = ValueNotifier<int>(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideMenuAnimation.builder(
        builder: (showMenu) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: Icon(Icons.menu, color: Colors.black), onPressed: showMenu),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              brightness: Brightness.light,
              centerTitle: true,
              title: ValueListenableBuilder<int>(
                valueListenable: _index,
                builder: (_, value, __) => Text(myMenuValue[value].title, style: TextStyle(color: Colors.black)),
              ),
            ),
            body: ValueListenableBuilder<int>(
              valueListenable: _index,
              builder: (_, value, __) => IndexedStack(
                index: value - 1,
                children: List.generate(
                  myMenuValue.length - 1,
                  (index) => Screen(itemsScreen: myMenuValue[index + 1].items),
                ),
              ),
            ),
          );
        },
        items: myMenuValue.map((value) => Icon(value.icon, color: Colors.white, size: 50)).toList(),
        selectedColor: Color(0xFFFF595E),
        unselectedColor: Color(0xFF1F2041),
        onItemSelected: (value) {
          if (value > 0 && value != _index.value) _index.value = value;
        },
      ),
    );
  }
}
```

You can follow me on twitter [@diegoveloper](https://www.twitter.com/diegoveloper)