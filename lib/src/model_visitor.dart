import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class ModelVisitor extends SimpleElementVisitor {
  String className = "";

  Map<String, dynamic> fields = {};
  Map<String, Map<dynamic, Map<String, dynamic>>> methods = {};
  @override
  void visitClassElement(ClassElement element) {
    // Read the class name directly from the ClassElement
    className = element.name;
    // You can also print or log the class name here if needed
    print("Visiting class: $className");

    // Visit any members of the class
    element.visitChildren(this);
  }

  @override
  visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();
    fields[element.name] = elementType.replaceFirst('*', '');
  }

  @override
  visitMethodElement(MethodElement element) {
    Map<String, dynamic> params = {};
    element.parameters.forEach((param) {
      params[param.name] = param.type.toString();
    });
    methods[element.name] = {element.returnType.toString(): params};
  }
}
