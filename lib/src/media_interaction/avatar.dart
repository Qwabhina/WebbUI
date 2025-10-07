import 'package:flutter/material.dart';
import 'package:webb_ui/src/feedback_status/feedback_status.dart';
import 'package:webb_ui/src/theme.dart';



class WebbUIAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double? size;
  final WebbUIStatusType? status;

  const WebbUIAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double avatarSize =
        isMobile ? context.iconTheme.mediumSize : context.iconTheme.largeSize;

    Widget avatarContent;
    if (imageUrl != null) {
      avatarContent = CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else if (initials != null) {
      avatarContent = CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: webbTheme.colorPalette.primary,
        child: Text(
          initials!,
          style: webbTheme.typography.labelLarge.copyWith(color: Colors.white),
        ),
      );
    } else {
      avatarContent = CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: webbTheme.colorPalette.neutralDark,
        child: Icon(Icons.person, color: Colors.white, size: avatarSize * 0.6),
      );
    }

    if (status != null) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatarContent,
          WebbUIStatusIndicator(type: status!),
        ],
      );
    }

    return avatarContent;
  }
}
