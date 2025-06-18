part of 'rfid_bloc.dart';

sealed class RfidState extends Equatable {
  const RfidState();
}

final class RfidInitial extends RfidState {
  @override
  List<Object> get props => [];
}

final class RfidScanResult extends RfidState {
  final List<RfidTag> tags;
  final String _id;
  RfidScanResult({required this.tags}) : _id = DateTime.now().toIso8601String();
  @override
  List<Object> get props => [tags, _id];
}

final class RfidConnectionStatus extends RfidState {
  final bool isConnected;
  final String _id;
  RfidConnectionStatus({required this.isConnected}) : _id = DateTime.now().toIso8601String();
  @override
  List<Object> get props => [isConnected, _id];
}