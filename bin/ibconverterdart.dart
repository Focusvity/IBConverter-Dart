import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

void main() {
  File plexFile = File('./indefbans.yml');
  if (plexFile.existsSync() == false) {
    plexFile.createSync();
  }

  stdout.write('Enter the path to the TotalFreedomMod indefinitebans.yml file: ');
  String path = stdin.readLineSync().toString();
  File tfmFile = File(path);
  if (tfmFile.existsSync() == false) {
    print('Cannot found a file with path $path');
    exit(-1);
  }

  Map yaml;
  try {
    yaml = loadYaml(tfmFile.readAsStringSync()) as Map;
  } on Exception catch (_) {
    print('Something went wrong while parsing yaml from ${tfmFile.path}... Is it formatted correctly?');
    exit(-1);
  }

  YAMLWriter writer = YAMLWriter(identSize: 1);
  String yamlString = """# Plex Indefinite Bans File
# Players with their UUID / IP / Usernames in here will be indefinitely banned until removed
  
# If you want to get someone's UUID, use https://api.ashcon.app/mojang/v2/user/<username>""";

  int i = 0;
  yaml.forEach((key, value) {
    print('Adding $key');
    String temp = writer.write({
      'users': [key]
    });

    if (value['uuid'] != null && !value['uuid'].isEmpty) {
      print('Adding ${value['uuid']}');
      temp += writer.write({
        'uuid': [value['uuid']]
      });
    }

    if (value['ips'] != null && !value['ips'].isEmpty) {
      print('Adding ${value['ips']}');
      temp += writer.write({'ips': value['ips']});
    }

    yamlString += writer.write({'$i': temp});
    i++;
  });

  plexFile.writeAsStringSync(yamlString.replaceAll(': |', ':'));

  print('-----------------------------------------------------------------------------------------------');
  print('Converted ${tfmFile.path.replaceFirst('./', '')} to Plex\'s format!');
  print('Your new file has been saved as \'indefbans.yml\' in the same directory the script was ran in.');
  print('The final step is to upload this to the Plex plugin folder.');
  print('-----------------------------------------------------------------------------------------------');
}
