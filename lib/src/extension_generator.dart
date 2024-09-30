import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:repo_annotation/repo_annotation.dart';

import 'model_visitor.dart';

class ExtensionGenerator extends GeneratorForAnnotation<ExtensionAnnotation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generateSource(element);
  }

  String _generateSource(Element element) {
    final visitor = ModelVisitor();

    // Debugging line to see the element type
    print(
        "Generating source for element: ${element.displayName} of type: ${element.runtimeType}");

    // Check if the element is a class or a mixin
    if (element is ClassElement) {
      element.accept(visitor);
      print("Class name captured: ${visitor.className}"); // Debugging line
    } else if (element is MixinElement) {
      element.accept(visitor);
      print("Mixin name captured: ${visitor.className}"); // Debugging line
    } else {
      throw Exception('Element is not a class or mixin');
    }

    // Construct the class or mixin implementation
    final className =
        "${visitor.className}Impl"; // Append "Impl" to the class/mixin name
    final classBuffer = StringBuffer();

    // Generate the implementation
    classBuffer.writeln("class $className with ${visitor.className} {");
    classBuffer.writeln("final ApiClient _apiClient;");
    classBuffer.writeln("$className(this._apiClient);");
    classBuffer.writeln('');

    // Generate methods
    visitor.methods.forEach((methodName, returnTypeAndParams) {
      final returnType = returnTypeAndParams.keys.first;
      Map<String, dynamic> params = returnTypeAndParams.values.first;

      final parameterString = _generateParameterString(params);
      final apiCallArguments = params.keys.join(", ");

      classBuffer.writeln("@override");
      classBuffer.writeln("$returnType $methodName($parameterString) async {");
      classBuffer.writeln("try {");
      classBuffer.writeln(
          "final response = await _apiClient.$methodName($apiCallArguments);");
      classBuffer.writeln("return ResponseHandler()..data = response;");
      classBuffer.writeln("} catch (error, stacktrace) {");
      classBuffer.writeln(
          'debugPrint("Exception occurred: \$error stacktrace: \$stacktrace");');
      classBuffer.writeln(
          'return ResponseHandler()..setException(ServerError.withError(error: error as DioException));');
      classBuffer.writeln("}");
      classBuffer.writeln("}");
      classBuffer.writeln(''); // Add a new line for better readability
    });

    classBuffer.writeln("}"); // Close the class definition

    return classBuffer.toString();
  }

  String _generateParameterString(Map<String, dynamic> params) {
    return params.entries
        .map((entry) => "required ${entry.value} ${entry.key}")
        .join(", ");
  }
}
