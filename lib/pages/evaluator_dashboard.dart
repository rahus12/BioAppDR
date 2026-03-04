import 'package:flutter/material.dart';
import 'package:bioappdr/services/ai_evaluator_service.dart';

/// Evaluator Dashboard - View AI Tutor quality metrics
/// Hidden page for developers/teachers to assess tutor performance
class EvaluatorDashboardPage extends StatefulWidget {
  const EvaluatorDashboardPage({super.key});

  @override
  State<EvaluatorDashboardPage> createState() => _EvaluatorDashboardPageState();
}

class _EvaluatorDashboardPageState extends State<EvaluatorDashboardPage> {
  final AiEvaluatorService _evaluatorService = AiEvaluatorService();
  bool _isLoading = true;
  List<EvaluationResult> _evaluations = [];
  Map<String, double> _averageScores = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _evaluatorService.loadEvaluations();
    setState(() {
      _evaluations = _evaluatorService.getEvaluationHistory();
      _averageScores = _evaluatorService.getAverageScores();
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await _evaluatorService.clearHistory();
    setState(() {
      _evaluations = [];
      _averageScores = {
        'accuracy': 0,
        'clarity': 0,
        'ageAppropriate': 0,
        'engagement': 0,
        'overall': 0,
      };
    });
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    if (score >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 4.0) return 'Great';
    if (score >= 3.0) return 'Good';
    if (score >= 2.0) return 'Needs Work';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade700],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Tutor Evaluator',
              style: TextStyle(
                fontFamily: 'LuckiestGuy',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Clear history',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Evaluation History?'),
                  content: const Text(
                    'This will delete all evaluation records. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _clearHistory();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Delete All',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(cs),
                  const SizedBox(height: 24),

                  // Score Breakdown
                  _buildScoreBreakdown(cs),
                  const SizedBox(height: 24),

                  // Recent Evaluations
                  Text(
                    'Recent Evaluations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  if (_evaluations.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _evaluations.length,
                      itemBuilder: (context, index) {
                        // Show newest first
                        final eval =
                            _evaluations[_evaluations.length - 1 - index];
                        return _buildEvaluationCard(eval, cs);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(ColorScheme cs) {
    final overall = _averageScores['overall'] ?? 0;
    final count = _evaluatorService.getEvaluationCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Overall Score Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(overall).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      overall > 0 ? overall.toStringAsFixed(1) : '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(overall),
                      ),
                    ),
                    Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Quality',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overall > 0 ? _getScoreLabel(overall) : 'No data yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getScoreColor(overall),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count evaluation${count == 1 ? '' : 's'} recorded',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(ColorScheme cs) {
    final scores = [
      {
        'label': 'Accuracy',
        'key': 'accuracy',
        'icon': Icons.fact_check,
        'description': 'Is the biology info correct?',
      },
      {
        'label': 'Clarity',
        'key': 'clarity',
        'icon': Icons.lightbulb,
        'description': 'Easy for kids to understand?',
      },
      {
        'label': 'Age Appropriate',
        'key': 'ageAppropriate',
        'icon': Icons.child_care,
        'description': 'Suitable for ages 5-12?',
      },
      {
        'label': 'Engagement',
        'key': 'engagement',
        'icon': Icons.star,
        'description': 'Interesting & encouraging?',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: scores.length,
          itemBuilder: (context, index) {
            final score = scores[index];
            final value = _averageScores[score['key']] ?? 0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        score['icon'] as IconData,
                        size: 20,
                        color: _getScoreColor(value),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          score['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        value > 0 ? value.toStringAsFixed(1) : '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(value),
                        ),
                      ),
                      Text(
                        '/5',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  // Progress bar
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation(_getScoreColor(value)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEvaluationCard(EvaluationResult eval, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getScoreColor(eval.overall).withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              eval.overall.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(eval.overall),
              ),
            ),
          ),
        ),
        title: Text(
          eval.question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDate(eval.timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: [
          // Tutor Response
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tutor Response:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  eval.response,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Score breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniScore('Accuracy', eval.accuracy),
              _buildMiniScore('Clarity', eval.clarity),
              _buildMiniScore('Age', eval.ageAppropriate),
              _buildMiniScore('Engage', eval.engagement),
            ],
          ),
          const SizedBox(height: 12),

          // Feedback
          if (eval.feedback.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eval.feedback,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniScore(String label, int score) {
    return Column(
      children: [
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score.toDouble()),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Evaluations Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with Bio Buddy and evaluations will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
