part of 'rfid_bloc.dart';

sealed class RfidEvent extends Equatable {
  const RfidEvent();
}

class InitRfidEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class StartScanEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class StopScanEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ConnectScannerEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class DisconnectScannerEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class StartTrackEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class RequestTagCountEvent extends RfidEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class DispatchScanResultEvent extends RfidEvent {
  final List<RfidTag> tags;
  final String _id;

  DispatchScanResultEvent({required this.tags})
    : _id = DateTime.now().toIso8601String();

  @override
  List<Object?> get props => [tags, _id];
}

class DispatchConnectionStatusEvent extends RfidEvent {
  final String _id;

  DispatchConnectionStatusEvent()
      : _id = DateTime.now().toIso8601String();

  @override
  List<Object?> get props => [_id];
}