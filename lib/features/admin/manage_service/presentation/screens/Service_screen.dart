import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_State.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_bloc.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/screens/Add_Service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.services),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddServicePage()),
          );
        },
        child: Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.search,
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is ServiceLoaded) {
                  if (state.services.isEmpty) {
                    return Center(
                      child: Text(l10n.noData),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.services.length,
                    itemBuilder: (_, i) {
                      final s = state.services[i];

                      return ListTile(
                        title: Text(s.nameAr),
                        subtitle: Text(s.nameEn),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddServicePage(service: s),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}