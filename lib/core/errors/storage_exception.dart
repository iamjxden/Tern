import 'humannode_exception.dart';
class StorageException extends HumanNodeException {
  const StorageException(super.message, {super.detail, super.stackTrace, super.cause});
}
