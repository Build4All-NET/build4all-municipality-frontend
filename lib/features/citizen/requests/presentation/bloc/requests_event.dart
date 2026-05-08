// lib/features/citizen/requests/presentation/bloc/requests_event.dart

abstract class RequestsEvent {
  const RequestsEvent();
}

class RequestsLoadRequested extends RequestsEvent {
  const RequestsLoadRequested();
}

class RequestsRefreshRequested extends RequestsEvent {
  const RequestsRefreshRequested();
}