import 'humannode_exception.dart';
class InferenceException extends HumanNodeException {
  const InferenceException(super.message, {super.detail, super.stackTrace, super.cause});
}
