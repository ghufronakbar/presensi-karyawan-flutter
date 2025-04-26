import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../constants/constants.dart';
import '../../../data/models/attendance_calendar_model.dart';
import '../../../data/providers/attendance_calendar_provider.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceCalendarProvider>(context, listen: false)
          .getAttendanceCalendar();
    });
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kehadiran'),
        elevation: 0,
      ),
      body: Consumer<AttendanceCalendarProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.calendarData == null) {
            return const Center(child: CircularProgressIndicator());
          }        
          
          return Column(
            children: [
              _buildTypeSelector(provider),
              _buildCalendarHeader(provider),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: MediaQuery.of(context).size.height * 0.45,
                child: _buildCalendar(provider),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              if (_selectedDay != null)
                Expanded(
                  child: _buildAttendanceDetails(provider, _selectedDay!),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTypeSelector(AttendanceCalendarProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTypeButton(
            title: 'Masuk', 
            isSelected: provider.currentType == AttendanceType.masuk,
            icon: Icons.login_rounded,
            onTap: () => provider.setAttendanceType(AttendanceType.masuk),
          ),
          const SizedBox(width: 16),
          _buildTypeButton(
            title: 'Keluar', 
            isSelected: provider.currentType == AttendanceType.keluar,
            icon: Icons.logout_rounded,
            onTap: () => provider.setAttendanceType(AttendanceType.keluar),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeButton({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendarHeader(AttendanceCalendarProvider provider) {
    final currentMonth = DateFormat('MMMM yyyy').format(provider.currentMonth);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  provider.previousMonth();
                  setState(() {
                    _focusedDay = DateTime(
                      provider.currentMonth.year,
                      provider.currentMonth.month,
                      1,
                    );
                  });
                },
              ),
              Text(
                currentMonth,
                style: AppTextStyles.heading6,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  provider.nextMonth();
                  setState(() {
                    _focusedDay = DateTime(
                      provider.currentMonth.year,
                      provider.currentMonth.month,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
          // ValueListenableBuilder<bool>(
          //   valueListenable: _isExpanded,
          //   builder: (context, isExpanded, _) {
          //     return IconButton(
          //       icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          //       onPressed: () => _isExpanded.value = !isExpanded,
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
  
  Widget _buildCalendar(AttendanceCalendarProvider provider) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        
        // Check if month has changed
        if (focusedDay.month != provider.currentMonth.month || 
            focusedDay.year != provider.currentMonth.year) {
          provider.setCurrentMonth(focusedDay);
        }
      },
      headerVisible: false,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle().copyWith(color: Colors.red),
        holidayTextStyle: const TextStyle().copyWith(color: Colors.blue[800]),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final records = provider.getRecordsForDay(day);
          
          if (records.isEmpty) {
            return null;
          }
          
          // Different marker shapes for different statuses
          final firstRecord = records.first;
          late Widget marker;
          
          switch (firstRecord.status.toLowerCase()) {
            case 'hadir':
              marker = Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                width: 8,
                height: 8,
              );
              break;
            case 'telat':
              marker = Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                width: 8,
                height: 8,
              );
              break;
            case 'ijin':
              marker = Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
              break;
            case 'sakit':
              marker = Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                ),
              );
              break;
            default:
              marker = Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
          }
          
          return Positioned(
            bottom: 1,
            right: 1,
            child: marker,
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          // Highlight today with different style
          if (isSameDay(day, DateTime.now())) {
            return Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildAttendanceDetails(AttendanceCalendarProvider provider, DateTime day) {
    final records = provider.getRecordsForDay(day);
    
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data kehadiran untuk\n${DateFormat('dd MMMM yyyy').format(day)}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Kehadiran ${DateFormat('EEEE, dd MMMM yyyy', 'id').format(day)}',
            style: AppTextStyles.heading6,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildAttendanceItem(record);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAttendanceItem(AttendanceRecord record) {
    final timeStr = DateFormat('HH:mm').format(record.time);
    final statusColor = record.getStatusColor();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (record.attachment != null) {
            _showAttachmentModal(context, record);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Icon(
                        record.type.toLowerCase() == 'masuk' 
                            ? Icons.login 
                            : Icons.logout,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.type} - ${timeStr}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                record.status.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (record.status.toLowerCase() == 'telat')
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  '${record.lateTime} menit',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            // Show attachment indicator if available
                            if (record.attachment != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.image,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (record.attachment != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAttachmentModal(BuildContext context, AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: record.getStatusColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        record.type.toLowerCase() == 'masuk' 
                            ? Icons.login 
                            : Icons.logout,
                        color: record.getStatusColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.type} - ${DateFormat('HH:mm').format(record.time)}',
                          style: AppTextStyles.heading6,
                        ),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id').format(record.time),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Attachment image
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lampiran',
                          style: AppTextStyles.heading6,
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: record.attachment ?? '',
                            placeholder: (context, url) => Container(
                              height: 300,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 