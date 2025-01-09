import 'package:flutter/material.dart';

class TimelineEvent {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime? completionDate;
  final String status;
  final List<String>? tasks;
  final double? progressPercentage;
  final String? assignee;
  bool isExpanded;

  TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon = Icons.circle,
    this.color = Colors.blue,
    this.completionDate,
    this.status = 'Upcoming',
    this.tasks,
    this.progressPercentage,
    this.assignee,
    this.isExpanded = false,
  });

  // Copy with method for easy modifications
  TimelineEvent copyWith({
    String? title,
    String? subtitle,
    String? description,
    IconData? icon,
    Color? color,
    DateTime? completionDate,
    String? status,
    List<String>? tasks,
    double? progressPercentage,
    String? assignee,
    bool? isExpanded,
  }) {
    return TimelineEvent(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      assignee: assignee ?? this.assignee,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  // Helper method to check if the event is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  // Helper method to check if the event is in progress
  bool get isInProgress => status.toLowerCase() == 'in progress';

  // Helper method to check if the event is upcoming
  bool get isUpcoming => status.toLowerCase() == 'upcoming';

  // Helper method to get formatted completion date
  String get formattedDate {
    if (completionDate == null) return 'No date set';
    return '${completionDate?.day}/${completionDate?.month}/${completionDate?.year}';
  }

  // Helper method to get the status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get remaining days until completion
  int? get remainingDays {
    if (completionDate == null) return null;
    final now = DateTime.now();
    return completionDate!.difference(now).inDays;
  }

  // Helper method to check if the event is overdue
  bool get isOverdue {
    if (completionDate == null || isCompleted) return false;
    return DateTime.now().isAfter(completionDate!);
  }

  // Helper method to get task completion percentage
  double get taskCompletionPercentage {
    if (tasks == null || tasks!.isEmpty) return 0.0;
    final completedTasks = tasks!.where((task) => task.startsWith('✓')).length;
    return (completedTasks / tasks!.length) * 100;
  }

  // Helper method to get formatted status text with icon
  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.trending_up;
      case 'upcoming':
        return Icons.upcoming;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method to get priority level based on date and status
  String get priority {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'High';
    if (isInProgress) return 'Medium';
    return 'Low';
  }

  // Helper method to get priority color
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'TimelineEvent(title: $title, status: $status, completionDate: ${formattedDate})';
  }
}