import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
class ModelVisitor extends SimpleElementVisitor {
  String className = "UnknownClass"; // Default value to prevent an empty name

  Map<String, dynamic> fields = {};
  Map<String, Map<dynamic, Map<String, dynamic>>> methods = {};

  @override
  void visitClassElement(ClassElement element) {
    className = element.name; // Capture the class name
    element.visitChildren(this);
  }

  @override
  void visitMixinElement(MixinElement element) {
    className = element.name; // Capture the mixin name
    element.visitChildren(this);
  }

  @override
  void visitConstructorElement(ConstructorElement element) {
    // Handle constructor logic, but we already captured class/mixin name in visitClassElement/visitMixinElement
  }

  @override
  void visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();
    fields[element.name] = elementType.replaceFirst('*', '');
  }

  @override
  void visitMethodElement(MethodElement element) {
    Map<String, dynamic> params = {};
    element.parameters.forEach((param) {
      params[param.name] = param.type.toString();
    });
    methods[element.name] = {element.returnType.toString(): params};
  }
}
