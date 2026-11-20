import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_colors.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.fetchTasks,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.error!),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: provider.fetchTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _dashboardBody(context, provider),
        );
      },
    );
  }

  Widget _dashboardBody(BuildContext context, TaskProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.fetchTasks,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeSection(),
          const SizedBox(height: 20),
          _statsSection(provider),
          const SizedBox(height: 20),
          _progressSection(provider),
          const SizedBox(height: 20),

          TextField(
            onChanged: provider.setSearch,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _filterSection(provider),
          const SizedBox(height: 16),

          if (provider.filteredTasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text('No tasks found'),
              ),
            ),

          ...provider.filteredTasks.map(
            (task) => _taskCard(context, provider, task),
          ),
        ],
      ),
    );
  }

  Widget _welcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good day 👋',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          'Let’s organize your work today.',
          style: TextStyle(color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _statsSection(TaskProvider provider) {
    return Row(
      children: [
        _statCard(
          'Total',
          provider.totalTasks,
          AppColors.primary,
          Icons.task_alt,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Pending',
          provider.pendingTasks,
          AppColors.orange,
          Icons.pending_actions,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Completed',
          provider.completedTasks,
          AppColors.green,
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _statCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _progressSection(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: provider.progress),
          const SizedBox(height: 8),
          Text('${(provider.progress * 100).toInt()}% completed'),
        ],
      ),
    );
  }

  Widget _filterSection(TaskProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Pending', 'Completed'].map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: provider.filter == filter,
              onSelected: (_) => provider.setFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _taskCard(
    BuildContext context,
    TaskProvider provider,
    TaskModel task,
  ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => provider.toggleTask(task.id),
        ),
        title: Text(
          task.title,
          maxLines: 2,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text('${task.category} • ${task.priority}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              provider.deleteTask(task.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
          );
        },
      ),
    );
  }
}
