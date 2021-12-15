import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/extension_generator.dart';
import 'src/subclass_generator.dart';

Builder extGen(BuilderOptions options) => SharedPartBuilder([ExtensionGenerator()], 'extension_generator');

Builder subclassGen(BuilderOptions options) => SharedPartBuilder([SubclassGenerator()], 'subclass_generator');
