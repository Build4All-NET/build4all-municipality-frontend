import 'package:baladiyati/features/admin/announcements/domain/Usecases/Create_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Get_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_Event.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final CreateAnnouncement createAnnouncement;
  final GetAnnouncements getAnnouncements;

  AnnouncementBloc(this.createAnnouncement, this.getAnnouncements)
      : super(AnnouncementInitial()) {

    on<LoadAnnouncements>((event, emit) async {
      emit(AnnouncementLoading());
      try {
        final list = await getAnnouncements();
        emit(AnnouncementLoaded(list));
      } catch (e) {
        emit(AnnouncementError("error loading"));
      }
    });

    on<CreateAnnouncementEvent>((event, emit) async {
      emit(AnnouncementLoading());
      try {
        await createAnnouncement(event.announcement);
        final list = await getAnnouncements();
        emit(AnnouncementLoaded(list));
      } catch (e) {
        emit(AnnouncementError("error creating"));
      }
    });
  }
}