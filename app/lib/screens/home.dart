import 'package:flutter/material.dart';

class LastSecretsScreen extends StatefulWidget {
  const LastSecretsScreen({Key? key}) : super(key: key);

  @override
  State<LastSecretsScreen> createState() => LastSecretsScreenState();
}

class LastSecretsScreenState extends State<LastSecretsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Welcome Title
            Text(
              'Welcome to pws_secrets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            // Last Secrets
            Text(
              'Last Secrets',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            // Last Secrets List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Secret $index'),
                    subtitle: Text('Description of Secret $index'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to Secret Screen
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // Key Rotation
            Text('Key Rotation', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
                'This is the key-rotation, it allowes you to rotate the key used by the server in the next key rotation. '
                'It makes it impossible for older secrets to be encrypted by deleting the key used. '),
          ],
        ),
      ),
    );
  }
}
