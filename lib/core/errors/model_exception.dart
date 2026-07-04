import 'humannode_exception.dart';
class ModelException extends HumanNodeException {
  const ModelException(super.message, {super.detail, super.stackTrace, super.cause});
}
