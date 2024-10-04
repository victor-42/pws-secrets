import 'package:flutter/material.dart';

class SecretsAccordion extends StatefulWidget {
  final String title;
  final Widget child;

  SecretsAccordion({
    Key? key,
    required this.title,
    required this.child,
  }): super(key: key);

  @override
  SecretsAccordionState createState() => SecretsAccordionState();
}

class SecretsAccordionState extends State<SecretsAccordion> {
  late bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void setExpanded(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 22,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Transform.rotate(
                    angle: _isExpanded ? 3.14 / 2 : 3.14 / 2 + 3.14,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Theme.of(context).textTheme.headlineMedium!.color,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                firstChild: Container(),
                secondChild: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(child: SelectionArea(child: widget.child)))),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              )
            ],
          ),
        ),
      ),
    );
  }
}
