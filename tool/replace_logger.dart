import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true, followLinks: false).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int count = 0;
  for (var file in files) {
    if (file.path.contains('logger.dart')) continue;
    
    var content = file.readAsStringSync();
    
    if (content.contains('debugPrint(')) {
      content = content.replaceAll('debugPrint(', 'appLog(');
      
      if (!content.contains('package:fastable/utils/logger.dart')) {
        // Insert import at the top
        final importLine = "import 'package:fastable/utils/logger.dart';\n";
        content = importLine + content;
      }
      
      file.writeAsStringSync(content);
      count++;
    }
  }
  
  print('Replaced debugPrint in \$count files');
}
