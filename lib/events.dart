import 'package:penniverse/exports.dart';

enum GlobalEventTypes{
  paymentUpdate,
  categoryUpdate,
  accountUpdate
}
final globalEvent = EventEmitter();