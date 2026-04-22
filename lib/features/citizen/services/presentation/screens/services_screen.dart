// lib/features/citizen/services/presentation/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'services_by_category_screen.dart';

class _Category {
  final String id;
  final String nameAr;
  final IconData icon;
  final Color color;
  final int count;
  const _Category({required this.id, required this.nameAr, required this.icon, required this.color, required this.count});
}

const List<_Category> _categories = [
  _Category(id: 'general', nameAr: 'الخدمات العامة', icon: Icons.description_outlined, color: Color(0xFF3B82F6), count: 8),
  _Category(id: 'commercial', nameAr: 'الخدمات التجارية والمهنية', icon: Icons.storefront_outlined, color: Color(0xFFF59E0B), count: 9),
  _Category(id: 'engineering', nameAr: 'الخدمات الهندسية', icon: Icons.engineering_outlined, color: Color(0xFF10B981), count: 7),
  _Category(id: 'realestate', nameAr: 'الخدمات العقارية', icon: Icons.apartment_outlined, color: Color(0xFF8B5CF6), count: 11),
  _Category(id: 'police', nameAr: 'الشرطة البلدية', icon: Icons.shield_outlined, color: Color(0xFFEF4444), count: 3),
  _Category(id: 'financial', nameAr: 'الخدمات المالية', icon: Icons.attach_money, color: Color(0xFF22C55E), count: 5),
];

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<_Category> get _filtered => _query.isEmpty
      ? _categories
      : _categories.where((c) => c.nameAr.contains(_query)).toList();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.municipalServices, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    textAlign: TextAlign.right,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchService,
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true, fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.selectCategory, textAlign: TextAlign.right, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  ..._filtered.map((cat) => GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ServicesByCategoryScreen(
                        categoryId: cat.id, categoryNameAr: cat.nameAr,
                        categoryColor: cat.color, categoryIcon: cat.icon,
                      ),
                    )),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                          const Spacer(),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(cat.nameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${cat.count} ${l10n.serviceCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ]),
                          const SizedBox(width: 16),
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(color: cat.color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                            child: Icon(cat.icon, color: cat.color, size: 28),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
