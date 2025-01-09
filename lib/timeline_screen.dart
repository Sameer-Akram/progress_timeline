import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'timeline_widget.dart';
import '../timeline_event.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with SingleTickerProviderStateMixin {
  late List<TimelineEvent> events;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  double _progress = 0.6; // Example progress value

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    events = [
      TimelineEvent(
        title: 'Discovery Phase',
        subtitle: 'Requirements & Analysis',
        description: 'Comprehensive stakeholder interviews, market research, and requirement gathering. Defining project scope, objectives, and success metrics.',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF1E88E5),
        completionDate: DateTime(2024, 1, 15),
        status: 'Completed',
      ),
      TimelineEvent(
        title: 'UX/UI Design',
        subtitle: 'User Experience Design',
        description: 'Creating user personas, journey maps, wireframes, and high-fidelity prototypes. Conducting user testing and iterating based on feedback.',
        icon: Icons.design_services,
        color: const Color(0xFF43A047),
        completionDate: DateTime(2024, 2, 28),
        status: 'Completed',
      ),
      TimelineEvent(
        title: 'Development Sprint',
        subtitle: 'Agile Implementation',
        description: 'Implementing core features using best practices and modern architecture. Regular code reviews and maintaining high code quality standards.',
        icon: Icons.code,
        color: const Color(0xFF7B1FA2),
        completionDate: DateTime(2024, 4, 15),
        status: 'In Progress',
      ),
      TimelineEvent(
        title: 'Quality Assurance',
        subtitle: 'Testing & Validation',
        description: 'Comprehensive testing including unit tests, integration tests, and end-to-end testing. Performance optimization and security auditing.',
        icon: Icons.verified_user,
        color: const Color(0xFFD81B60),
        completionDate: DateTime(2024, 5, 30),
        status: 'Upcoming',
      ),
      TimelineEvent(
        title: 'Production Release',
        subtitle: 'Deployment & Monitoring',
        description: 'Coordinated deployment across all platforms, monitoring system health, and implementing feedback loops for continuous improvement.',
        icon: Icons.rocket_launch,
        color: const Color(0xFFFF7043),
        completionDate: DateTime(2024, 6, 15),
        status: 'Upcoming',
      ),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.grey[50]!,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildProjectHeader(),
                _buildProgressSection(),
                const SizedBox(height: 16),
                Expanded(
                  child: TimelineWidget(events: events),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black87),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.black87),
          onPressed: () => _showInfoDialog(),
        ),
      ],
      title: const Text(
        'Project Timeline',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Phoenix',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started: January 15, 2024',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip('On Track', Colors.green),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 8,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('Completed', '2/5', Colors.green),
              _buildProgressStat('In Progress', '1/5', Colors.orange),
              _buildProgressStat('Upcoming', '2/5', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Timeline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildFilterOption('All Milestones', true),
            _buildFilterOption('Completed', false),
            _buildFilterOption('In Progress', false),
            _buildFilterOption('Upcoming', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool selected) {
    return ListTile(
      title: Text(label),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () {
        Navigator.pop(context);
        // Implement filter logic
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.timeline,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Project Timeline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This timeline shows the key milestones and progress of our project. '
                  'Each stage can be expanded to view more details about the activities '
                  'and deliverables.',
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.touch_app,
              'Tap any milestone to see detailed information',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Track progress and upcoming deadlines',
            ),
            _buildInfoItem(
              Icons.update,
              'Real-time status updates for each phase',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}

