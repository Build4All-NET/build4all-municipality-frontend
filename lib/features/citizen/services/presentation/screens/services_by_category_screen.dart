// lib/features/citizen/services/presentation/screens/services_by_category_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'new_request_screen.dart';

class ServiceItem {
  final String id;
  final String nameAr;
  final String descriptionAr;
  final int fee;
  final int processingDays;
  final bool requiresInspection;
  final List<String> requiredDocs;

  const ServiceItem({
    required this.id,
    required this.nameAr,
    required this.descriptionAr,
    required this.fee,
    required this.processingDays,
    this.requiresInspection = false,
    this.requiredDocs = const [],
  });
}

// Hardcoded services per category
final Map<String, List<ServiceItem>> servicesByCategory = {
  'general': [
    ServiceItem(
      id: 'g1',
      nameAr: 'شكوى أو مراجعة',
      descriptionAr: 'تقديم شكوى أو مراجعة بلدية مع تحديد الموقع وإرفاق الصور',
      fee: 0,
      processingDays: 7,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'صور توضيحية'],
    ),
    ServiceItem(
      id: 'g2',
      nameAr: 'طلب إفادة',
      descriptionAr: 'إفادة سكن / تعريف / غيرها',
      fee: 10000,
      processingDays: 3,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية أو عقد الإيجار'],
    ),
    ServiceItem(
      id: 'g3',
      nameAr: 'براءة ذمة بلدية',
      descriptionAr: 'التحقق من خلو الذمة المالية وإصدار الشهادة',
      fee: 5000,
      processingDays: 2,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية'],
    ),
    ServiceItem(
      id: 'g4',
      nameAr: 'إذن إشغال رصيف / أملاك عامة',
      descriptionAr: 'استئذان لاستخدام مساحة من الأملاك العامة أو الأرصفة',
      fee: 50000,
      processingDays: 10,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'مخطط الموقع'],
    ),
    ServiceItem(
      id: 'g5',
      nameAr: 'ترخيص إعلان / لافتة',
      descriptionAr: 'ترخيص إعلانات دائمة أو مؤقتة مع تحديد الحجم والموقع',
      fee: 30000,
      processingDays: 7,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'تصميم اللافتة', 'مخطط الموقع'],
    ),
    ServiceItem(
      id: 'g6',
      nameAr: 'ترخيص محل / مؤسسة',
      descriptionAr: 'إصدار أو تجديد رخصة تشغيل محل تجاري أو مؤسسة',
      fee: 100000,
      processingDays: 14,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'عقد الإيجار', 'سجل تجاري'],
    ),
    ServiceItem(
      id: 'g7',
      nameAr: 'حجز قاعة / مرفق بلدي',
      descriptionAr: 'حجز مرافق أو قاعات بلدية للاستخدام المؤقت',
      fee: 75000,
      processingDays: 5,
      requiredDocs: ['هوية شخصية', 'طلب رسمي'],
    ),
    ServiceItem(
      id: 'g8',
      nameAr: 'طلب صيانة',
      descriptionAr: 'الإبلاغ عن أعطال الخدمات العامة (إنارة / حفريات / نفايات)',
      fee: 0,
      processingDays: 3,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'صور المشكلة'],
    ),
  ],
  'commercial': [
    ServiceItem(
      id: 'c1',
      nameAr: 'رخصة محل تجاري',
      descriptionAr: 'إصدار رخصة لمحل تجاري جديد',
      fee: 100000,
      processingDays: 14,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'عقد الإيجار', 'سجل تجاري', 'مخطط المحل'],
    ),
    ServiceItem(
      id: 'c2',
      nameAr: 'تجديد رخصة تجارية',
      descriptionAr: 'تجديد رخصة محل تجاري قائم',
      fee: 75000,
      processingDays: 7,
      requiredDocs: ['هوية شخصية', 'رخصة قديمة', 'سجل تجاري'],
    ),
    ServiceItem(
      id: 'c3',
      nameAr: 'رخصة مطعم / كافيه',
      descriptionAr: 'ترخيص لفتح مطعم أو كافيه',
      fee: 150000,
      processingDays: 21,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'عقد الإيجار', 'تقرير صحي', 'مخطط'],
    ),
  ],
  'engineering': [
    ServiceItem(
      id: 'e1',
      nameAr: 'رخصة بناء',
      descriptionAr: 'الحصول على إذن لبناء منزل أو مبنى جديد',
      fee: 200000,
      processingDays: 30,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية', 'المخططات الهندسية', 'تقرير المهندس'],
    ),
    ServiceItem(
      id: 'e2',
      nameAr: 'رخصة هدم',
      descriptionAr: 'إذن لهدم مبنى أو جزء منه',
      fee: 100000,
      processingDays: 14,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية', 'تقرير المهندس'],
    ),
    ServiceItem(
      id: 'e3',
      nameAr: 'شهادة إشغال',
      descriptionAr: 'شهادة بانتهاء أعمال البناء وصلاحية الإشغال',
      fee: 50000,
      processingDays: 10,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'رخصة البناء', 'المخططات النهائية'],
    ),
  ],
  'realestate': [
    ServiceItem(
      id: 'r1',
      nameAr: 'شهادة تسجيل عقار',
      descriptionAr: 'تسجيل عقار في السجلات البلدية',
      fee: 80000,
      processingDays: 15,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية', 'مخطط العقار'],
    ),
    ServiceItem(
      id: 'r2',
      nameAr: 'نقل ملكية عقار',
      descriptionAr: 'تحويل ملكية عقار من شخص لآخر',
      fee: 150000,
      processingDays: 20,
      requiredDocs: ['هويات الطرفين', 'وثيقة الملكية', 'عقد البيع'],
    ),
  ],
  'police': [
    ServiceItem(
      id: 'p1',
      nameAr: 'بلاغ شرطة بلدية',
      descriptionAr: 'تقديم بلاغ لشرطة البلدية',
      fee: 0,
      processingDays: 1,
      requiredDocs: ['هوية شخصية'],
    ),
    ServiceItem(
      id: 'p2',
      nameAr: 'طلب حماية أملاك',
      descriptionAr: 'طلب حماية الأملاك الخاصة أو العامة',
      fee: 0,
      processingDays: 3,
      requiresInspection: true,
      requiredDocs: ['هوية شخصية', 'وثيقة الملكية'],
    ),
  ],
  'financial': [
    ServiceItem(
      id: 'f1',
      nameAr: 'دفع ضريبة بلدية',
      descriptionAr: 'دفع الضرائب البلدية المستحقة',
      fee: 0,
      processingDays: 1,
      requiredDocs: ['هوية شخصية', 'إشعار الضريبة'],
    ),
    ServiceItem(
      id: 'f2',
      nameAr: 'طلب إعفاء ضريبي',
      descriptionAr: 'التقدم بطلب إعفاء من الضرائب البلدية',
      fee: 0,
      processingDays: 30,
      requiredDocs: ['هوية شخصية', 'وثائق داعمة'],
    ),
  ],
};

class ServicesByCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryNameAr;
  final Color categoryColor;
  final IconData categoryIcon;

  const ServicesByCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<ServicesByCategoryScreen> createState() =>
      _ServicesByCategoryScreenState();
}

class _ServicesByCategoryScreenState
    extends State<ServicesByCategoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<ServiceItem> get _services =>
      servicesByCategory[widget.categoryId] ?? [];

  List<ServiceItem> get _filtered => _query.isEmpty
      ? _services
      : _services
          .where((s) => s.nameAr.contains(_query) ||
              s.descriptionAr.contains(_query))
          .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              widget.categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.categoryIcon,
                            color: widget.categoryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.categoryNameAr,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_filtered.length} ${l10n.serviceCount}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search
                  TextField(
                    controller: _searchCtrl,
                    textAlign: TextAlign.right,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchInServices,
                      hintStyle:
                          const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(l10n.noServices,
                          style:
                              const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final s = _filtered[i];
                        return _ServiceCard(
                          service: s,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NewRequestScreen(service: s),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;
  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.requiresInspection)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.requiresInspection,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  )
                else
                  const SizedBox(),
                Expanded(
                  child: Text(
                    service.nameAr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              service.descriptionAr,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.access_time,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${service.processingDays} ${l10n.days}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money,
                    size: 14, color: Colors.grey),
                Text(
                  service.fee == 0
                      ? l10n.free
                      : '${_fmt(service.fee)} ${l10n.lbp}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
