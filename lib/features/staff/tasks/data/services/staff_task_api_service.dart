import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:dio/dio.dart';

class StaffTaskApiService {
  StaffTaskApiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  final Dio _dio;

  Future<List<StaffTaskModel>> getTasksByProcessInstanceKey(
    int processInstanceKey,
  ) async {
    final response = await _dio.get(
      '/api/camunda/tasks/process/$processInstanceKey',
    );

    final rawTasks = _extractTaskList(response.data);

    return rawTasks.map(StaffTaskModel.fromJson).toList();
  }

  Future<Map<String, dynamic>> getTaskById(int taskId) async {
    final response = await _dio.get('/api/camunda/tasks/$taskId');

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getTaskForm(int taskId) async {
    final response = await _dio.get('/api/camunda/tasks/$taskId/form');

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> completeTask({
    required int taskId,
    required Map<String, dynamic> variables,
  }) async {
    final response = await _dio.post(
      '/api/camunda/tasks/$taskId/complete',
      data: variables,
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> assignTask({
    required int taskId,
    required String assignee,
  }) async {
    final response = await _dio.post(
      '/api/camunda/tasks/$taskId/assign',
      data: {
        'assignee': assignee,
      },
    );

    return _asMap(response.data);
  }

  Future<void> unassignTask(int taskId) async {
    await _dio.delete('/api/camunda/tasks/$taskId/unassign');
  }

  List<Map<String, dynamic>> _extractTaskList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final candidates = [
        map['items'],
        map['tasks'],
        map['data'],
        map['results'],
        map['content'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }
}