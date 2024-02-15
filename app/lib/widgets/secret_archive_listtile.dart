import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';

class SArchiveTile extends StatelessWidget {
  final SecretArchive secretArchive;

  SArchiveTile({required this.secretArchive});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: this.secretArchive.openedAt == null
                ? Colors.green
                : Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 40,
              child: OutlinedButton(
                  onPressed: () {},
                  child: Icon(Icons.do_not_disturb_on_outlined)),
            ),
            Row(
              children: [
                Text(this.secretArchive.openedAt == null
                    ? 'Unopened'
                    : 'Opened'),
                SizedBox(width: 10),
                Text(this.secretArchive.openedAt == null
                    ? ''
                    : this.secretArchive.openedAt.toString().substring(0, 10)),
              ],
            ),
            SizedBox(
              height: 40,
              child: OutlinedButton(

                  onPressed: () {},
                  child: Icon(Icons.timelapse),),
            ),
          ],
        ),
      ),
    );
  }
}
