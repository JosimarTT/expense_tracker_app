import 'package:flutter/material.dart';

import '../domain/profile.dart';

extension ProfileAvatarPresentation on ProfileAvatar {
  String get label => switch (this) {
    ProfileAvatar.neko => 'Neko',
    ProfileAvatar.piggy => 'Piggy',
    ProfileAvatar.kuma => 'Kuma',
    ProfileAvatar.boba => 'Boba',
  };

  String get emoji => switch (this) {
    ProfileAvatar.neko => '🐱',
    ProfileAvatar.piggy => '🐷',
    ProfileAvatar.kuma => '🐻',
    ProfileAvatar.boba => '☕',
  };
}

class ProfileAvatarIcon extends StatelessWidget {
  const ProfileAvatarIcon({required this.avatar, super.key});

  final ProfileAvatar avatar;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Text(avatar.emoji, style: const TextStyle(fontSize: 28)),
  );
}
