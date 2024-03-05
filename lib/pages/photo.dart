import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../provider/counter.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    var counterProvider = Provider.of<Counter>(context);

    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PhotoPage--${counterProvider.count}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            FilledButton(
                child: const Text("provider增加"),
                onPressed: () {
                  counterProvider.incCount();
                })
          ],
        ),
      ),
    );
  }
}
