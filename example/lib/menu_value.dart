import 'package:flutter/material.dart';

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
