import 'package:flutter/material.dart';

import '../theme.dart';

class RadioCardButton extends StatelessWidget {
  final String title;
  final Widget iconWidget;
  final bool active;
  final Function onClicked;

  RadioCardButton({
    required this.title,
    required this.iconWidget,
    required this.active,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      mouseCursor: active ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onTap: () => onClicked(),
      child: SizedBox(
        width: 100,
        height: 100,
        child: active ? _buildActiveCard() : _buildInactiveCard(),
      ),
    );
  }

  Widget _buildActiveCard() {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: primary_color,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _buildCardContent(),
    );
  }

  Widget _buildInactiveCard() {
    return Card(
      elevation: 1,
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 40,
            ),
            child: iconWidget),
      ],
    );
  }
}


class HomeSecretButtons extends StatelessWidget {
  final Function onClick;
  final String assetPath;

  HomeSecretButtons({
    required this.onClick,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onClick(),
        child: Card(
          child:
          Container(
            padding: const EdgeInsets.all(23),

              child: Image.asset(
                assetPath,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                height: 30,
              ),
            ),
        ),
      ),
    );
  }
}
