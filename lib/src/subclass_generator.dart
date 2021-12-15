import 'package:repo_annotation/repo_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';

import 'model_visitor.dart';

class SubclassGenerator extends GeneratorForAnnotation<SubclassAnnotation> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generatedSource(element);
  }

  String _generatedSource(Element element) {
    var visitor = ModelVisitor();

    element.visitChildren(visitor);

    var className = "${visitor.className}Impl";

    var classBuffer = StringBuffer();

    // class *Model*Impl
    classBuffer.writeln("class $className extends ${visitor.className} {");

    classBuffer.writeln("final ApiClient _apiClient;");
    classBuffer.writeln("${className}(this._apiClient);");
    classBuffer.writeln('');

    //method
    for(var methodName in visitor.methods.keys){
      String parameters = "{";
      String parametersApi = '';
      visitor.methods[methodName]?.values.first.forEach((key, value) {
        parameters += "required ${value} ${key}";
        parametersApi += "${key}, ";
      });
      if(parameters.length == 1){
        parameters = '';
        parametersApi = '';
      }
      else {
        parameters += "}";
        parametersApi.substring(0, parametersApi.length - 2);
      }
      classBuffer.writeln("@override");
      classBuffer.writeln("${visitor.methods[methodName]?.keys.first} ${methodName} (${parameters}) async {");
      classBuffer.writeln("${visitor.methods[methodName]?.keys.first.toString().replaceAll('Future<ResponseHandler<', '').replaceAll('>>', '')}? response;");
      classBuffer.writeln("try{");
      classBuffer.writeln("response = await _apiClient.${methodName}(${parametersApi});");
      classBuffer.writeln("} catch(error, stacktrace) {");
      classBuffer.writeln('debugPrint("Exception occurred: \$error stacktrace: \$stacktrace");');
      classBuffer.writeln('return ResponseHandler()..setException(ServerError.withError(error: error as DioError),);');
      classBuffer.writeln('}');
      classBuffer.writeln('return ResponseHandler()..data = response;');
      classBuffer.writeln('}');
    }

    // class ends here
    classBuffer.writeln("}");

    return classBuffer.toString();
  }
}
