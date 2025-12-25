import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../appointments/presentation/controller/appointments_controller.dart';
import '../../../../core/network/hms_dio_factory.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../appointments/presentation/pages/appointment_detail_page.dart';
import '../../../appointments/data/models/doctor.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  late final AppointmentsController controller;
  late DateTime selectedDate;
  String? selectedTime;
  Doctor? selectedDoctor;
  String priority = 'normal';
  String? currentUserId;

  final List<String> morningSlots = const [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
  ];

  final List<String> afternoonSlots = const [
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    controller = Get.put(
      AppointmentsController(
        repo: AppointmentRepository(
          dio: HmsDioFactory.create(baseUrl: 'https://hms.celiyo.com'),
        ),
      ),
      permanent: true,
    );

    if (controller.appointments.isEmpty && !controller.isLoading.value) {
      Future.microtask(() => controller.loadAppointments());
    }
    Future.microtask(() => controller.loadDoctors());
    _loadCurrentUser();
  }

  Widget _buildDoctorPicker(void Function(void Function()) setModalState) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final doctors = controller.doctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor *',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (controller.isLoadingDoctors.value) return;
            final picked = await showModalBottomSheet<Doctor>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: const [
                            Text(
                              'Select Doctor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (controller.isLoadingDoctors.value)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      else if (doctors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No doctors available'),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: doctors.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final doc = doctors[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      primaryColor.withOpacity(0.1),
                                  child: Text(
                                    doc.name.isNotEmpty
                                        ? doc.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                title: Text(doc.name),
                                subtitle: doc.specialty != null
                                    ? Text(doc.specialty!)
                                    : null,
                                onTap: () => Navigator.of(context).pop(doc),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );

            if (picked != null) {
              setModalState(() {
                selectedDoctor = picked;
              });
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ??
                  theme.cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDoctor?.name ?? 'Select doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selectedDoctor == null
                          ? theme.hintColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown(void Function(void Function()) setModalState) {
    final theme = Theme.of(context);
    const options = [
      {'value': 'low', 'label': 'Low'},
      {'value': 'normal', 'label': 'Normal'},
      {'value': 'high', 'label': 'High'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor ??
                theme.cardColor.withOpacity(0.6),
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: priority,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: options
                  .map(
                    (o) => DropdownMenuItem<String>(
                      value: o['value']!,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: o['value'] == 'high'
                                  ? Colors.red
                                  : o['value'] == 'normal'
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                          Text(
                            o['label']!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setModalState(() {
                    priority = v;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadCurrentUser() async {
    final id = await TokenStorage.instance.getUserId();
    if (mounted) {
      setState(() {
        currentUserId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final hasError = controller.error.value.isNotEmpty;
        final isEmpty = controller.appointments.isEmpty;

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshList,
                  child: ListView(
                    padding: EdgeInsets.all(context.padding(16)),
                    children: [
                      _buildHeader(theme),
                      SizedBox(height: context.spacing(16)),
                      _buildDateSelector(),
                      SizedBox(height: context.spacing(12)),
                      _buildSlotSection('Morning Set', morningSlots),
                      SizedBox(height: context.spacing(12)),
                      _buildSlotSection('Afternoon Set', afternoonSlots),
                      SizedBox(height: context.spacing(20)),
                      ElevatedButton(
                        onPressed: () => _openCreateSheet(
                          context,
                          prefillDate: selectedDate,
                          prefillTime: selectedTime,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size.fromHeight(context.spacing(52)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Add Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: context.fontSize(16),
                          ),
                        ),
                      ),
                      SizedBox(height: context.spacing(24)),
                      Text(
                        'Your Appointments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: context.fontSize(16),
                        ),
                      ),
                      SizedBox(height: context.spacing(10)),
                      if (isLoading)
                        Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.padding(12)),
                          child: const CircularProgressIndicator(),
                        )),
                      if (hasError) _buildErrorState(),
                      if (!isLoading && !hasError && isEmpty) _buildEmptyState(),
                      if (!isLoading && !hasError && !isEmpty)
                        ...List.generate(
                          controller.appointments.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: context.spacing(14)),
                            child: _buildAppointmentCard(
                              controller.appointments[i],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final month = DateFormat('MMM yyyy').format(selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                // optional: navigate back if needed
              },
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Make Appointment',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Select your visit date & Time',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You can choose the date and time from the available doctor\'s schedule',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose Day, $month',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final days = List.generate(7, (i) => selectedDate.add(Duration(days: i)));
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final selectedText = theme.colorScheme.onPrimary;
    final unselectedText = theme.colorScheme.onSurfaceVariant;
    final unselectedBg = theme.colorScheme.surfaceVariant;

    return SizedBox(
      height: context.spacing(86),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => SizedBox(width: context.spacing(8)),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, selectedDate);
          final dayName = DateFormat('E').format(day);
          final dayNum = DateFormat('d').format(day);
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = day;
              });
            },
            child: Container(
              width: context.spacing(68),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : unselectedBg,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(vertical: context.padding(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? selectedText : unselectedText,
                      fontWeight: FontWeight.w600,
                      fontSize: context.fontSize(13),
                    ),
                  ),
                  SizedBox(height: context.spacing(6)),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? selectedText : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: context.fontSize(18),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotSection(String title, List<String> slots) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: context.fontSize(15),
          ),
        ),
        SizedBox(height: context.spacing(10)),
        Wrap(
          spacing: context.spacing(10),
          runSpacing: context.spacing(10),
          children: slots.map((slot) {
            final isSelected = slot == selectedTime;
            final isDisabled = false; // hook to disable if needed
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: isDisabled
                  ? null
                  : (v) {
                      setState(() {
                        selectedTime = slot;
                      });
                    },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: context.fontSize(14),
              ),
              backgroundColor:
                  isDisabled ? theme.disabledColor.withOpacity(0.2) : theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : theme.dividerColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 58,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Book or create a new appointment to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Get.toNamed('/book-appointment'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                  ),
                  child: const Text('Book'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _openCreateSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final statusIcon = _getStatusIcon(appointment.status);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(0.4);
    final textColor = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        Get.to(() => AppointmentDetailPage(appointment: appointment));
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: appointment.doctorImage != null
                        ? ClipOval(
                            child: Image.network(
                              appointment.doctorImage!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 28,
                                color: primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 28,
                            color: primaryColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName ?? 'Doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty ?? 'Specialist',
                          style: TextStyle(
                            fontSize: 14,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatStatus(appointment.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                            const SizedBox(height: 2),
                            Text(
                              appointment.appointmentDate != null
                                  ? DateFormat('MMM dd, yyyy').format(
                                      DateTime.parse(
                                          appointment.appointmentDate!))
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time,
                            size: 18,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                            const SizedBox(height: 2),
                            Text(
                              appointment.appointmentTime ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateSheet(
    BuildContext context, {
    DateTime? prefillDate,
    String? prefillTime,
  }) {
    final complaintCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final appointmentTypeIdCtrl = TextEditingController();
    DateTime? selectedDateLocal = prefillDate ?? DateTime.now();
    TimeOfDay? selectedTimeLocal = prefillTime != null
        ? TimeOfDay(
            hour: int.parse(prefillTime.split(':')[0]),
            minute: int.parse(prefillTime.split(':')[1]),
          )
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) {
            return Padding(
              padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> pickDate() async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDateLocal ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 0)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() {
                        selectedDateLocal = picked;
                      });
                    }
                  }

                  Future<void> pickTime() async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTimeLocal ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setModalState(() {
                        selectedTimeLocal = picked;
                      });
                    }
                  }

                  Future<void> submit() async {
                    if (selectedDateLocal == null ||
                        selectedTimeLocal == null) {
                      Get.snackbar(
                        'Missing info',
                        'Select both date and time',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    int? parseInt(String v) {
                      if (v.trim().isEmpty) return null;
                      return int.tryParse(v.trim());
                    }

                    final doctorId = selectedDoctor?.id;
                    final appointmentTypeId =
                        parseInt(appointmentTypeIdCtrl.text);

                    if (doctorId == null) {
                      Get.snackbar(
                        'Missing info',
                        'Doctor is required',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    final dateStr =
                        DateFormat('yyyy-MM-dd').format(selectedDateLocal!);
                    final timeStr =
                        '${selectedTimeLocal!.hour.toString().padLeft(2, '0')}:${selectedTimeLocal!.minute.toString().padLeft(2, '0')}:00';

                    final complaint = complaintCtrl.text.trim().isEmpty
                        ? 'General consultation'
                        : complaintCtrl.text.trim();
                    final notes = notesCtrl.text.trim();

                    final payload = <String, dynamic>{
                      'appointment_date': dateStr,
                      'appointment_time': timeStr,
                      'status': 'scheduled',
                      'priority': priority,
                      // Backend will determine patient_id from authenticated user
                      'doctor_id': doctorId,
                      if (appointmentTypeId != null)
                        'appointment_type_id': appointmentTypeId,
                      'chief_complaint': complaint,
                    };

                    if (notes.isNotEmpty) {
                      payload['notes'] = notes;
                    }

                    final ok = await controller.createAppointment(payload);
                    if (ok && mounted) {
                      Navigator.of(context).pop();
                    }
                  }

                  final theme = Theme.of(context);
                  return Material(
                    color: theme.scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.dividerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'New Appointment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pick date & time',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: pickDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      selectedDateLocal != null
                                          ? DateFormat('MMM dd, yyyy')
                                              .format(selectedDateLocal!)
                                          : 'Select date',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: pickTime,
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      selectedTimeLocal != null
                                          ? selectedTimeLocal!.format(context)
                                          : 'Select time',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDoctorPicker(setModalState),
                            const SizedBox(height: 12),
                            TextField(
                              controller: appointmentTypeIdCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Appointment Type ID (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPriorityDropdown(setModalState),
                            const SizedBox(height: 12),
                            TextField(
                              controller: complaintCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Chief complaint',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: notesCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Notes (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  'Create Appointment',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_progress':
        return Icons.timelapse;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
