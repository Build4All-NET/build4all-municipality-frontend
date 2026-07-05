import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Create_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Delete_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Get_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Update_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_Event.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final CreateAnnouncement createAnnouncement;
  final GetAnnouncements getAnnouncements;
  final UpdateAnnouncement updateAnnouncement;
  final DeleteAnnouncement deleteAnnouncement;

  AnnouncementBloc({
    required this.createAnnouncement,
    required this.getAnnouncements,
    required this.updateAnnouncement,
    required this.deleteAnnouncement,
  }) : super(AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoad);
    on<CreateAnnouncementEvent>(_onCreate);
    on<UpdateAnnouncementEvent>(_onUpdate);
    on<DeleteAnnouncementEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());

    try {
    
      final list = await getAnnouncements();
      emit(AnnouncementLoaded(list));
    } catch (e) {
      emit(AnnouncementError(errorMessage(e)));
    }
  }

  Future<void> _onCreate(
    CreateAnnouncementEvent event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());

    try {
      await createAnnouncement(event.announcement);
      final list = await getAnnouncements();
      emit(AnnouncementLoaded(list));
    } catch (e) {
      emit(AnnouncementError(errorMessage(e)));
    }
  }

  Future<void> _onUpdate(
    UpdateAnnouncementEvent event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());

    try {
      await updateAnnouncement(event.id, event.announcement);
      final list = await getAnnouncements();
      emit(AnnouncementLoaded(list));
    } catch (e) {
      emit(AnnouncementError(errorMessage(e)));
    }
  }

  Future<void> _onDelete(
    DeleteAnnouncementEvent event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());

    try {
      await deleteAnnouncement(event.id);
      final list = await getAnnouncements();
      emit(AnnouncementLoaded(list));
    } catch (e) {
      emit(AnnouncementError(errorMessage(e)));
    }
  }
}