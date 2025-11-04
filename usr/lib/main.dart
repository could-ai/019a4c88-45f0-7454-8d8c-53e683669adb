import 'package:flutter/material.dart';

void main() {
  runApp(const CricketTrackerApp());
}

class CricketTrackerApp extends StatelessWidget {
  const CricketTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Career Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0d1117),
        cardColor: const Color(0xFF161b22),
        primaryColor: const Color(0xFF58a6ff),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFFc9d1d9),
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: Color(0xFFc9d1d9),
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFc9d1d9),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF161b22),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8b949e)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF58a6ff)),
          ),
          labelStyle: TextStyle(color: Color(0xFFc9d1d9)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const CricketTrackerHome(),
    );
  }
}

class Performance {
  final String name;
  final int runsScored;
  final int ballsFaced;
  final int wicketsTaken;
  final int runsConceded;
  final DateTime timestamp;

  Performance({
    required this.name,
    required this.runsScored,
    required this.ballsFaced,
    required this.wicketsTaken,
    required this.runsConceded,
    required this.timestamp,
  });
}

class CricketTrackerHome extends StatefulWidget {
  const CricketTrackerHome({super.key});

  @override
  State<CricketTrackerHome> createState() => _CricketTrackerHomeState();
}

class _CricketTrackerHomeState extends State<CricketTrackerHome> {
  final List<Performance> _performances = [];
  final _formKey = GlobalKey<FormState>();
  final _entryNameController = TextEditingController();
  final _runsScoredController = TextEditingController(text: '0');
  final _ballsFacedController = TextEditingController(text: '0');
  final _wicketsTakenController = TextEditingController(text: '0');
  final _runsConcededController = TextEditingController(text: '0');

  String _message = '';

  void _addPerformance() {
    if (_formKey.currentState!.validate()) {
      final performance = Performance(
        name: _entryNameController.text.trim().isNotEmpty
            ? _entryNameController.text.trim()
            : 'Performance ${DateTime.now().toLocal().toString().split(' ')[0]}',
        runsScored: int.parse(_runsScoredController.text),
        ballsFaced: int.parse(_ballsFacedController.text),
        wicketsTaken: int.parse(_wicketsTakenController.text),
        runsConceded: int.parse(_runsConcededController.text),
        timestamp: DateTime.now(),
      );

      setState(() {
        _performances.add(performance);
        _performances.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _message = 'Performance saved successfully!';
      });

      _formKey.currentState!.reset();
      _runsScoredController.text = '0';
      _ballsFacedController.text = '0';
      _wicketsTakenController.text = '0';
      _runsConcededController.text = '0';
      _entryNameController.clear();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _message = '';
          });
        }
      });
    }
  }

  Map<String, dynamic> _calculateMetrics() {
    int totalRuns = 0;
    int totalBallsFaced = 0;
    int totalWickets = 0;
    int totalRunsConceded = 0;
    int centuryCount = 0;
    int inningsPlayed = _performances.length;

    for (final stat in _performances) {
      totalRuns += stat.runsScored;
      totalBallsFaced += stat.ballsFaced;
      totalWickets += stat.wicketsTaken;
      totalRunsConceded += stat.runsConceded;

      if (stat.runsScored >= 100) {
        centuryCount++;
      }
    }

    double battingAverage = inningsPlayed > 0 ? totalRuns / inningsPlayed : 0.0;
    double strikeRate = totalBallsFaced > 0 ? (totalRuns / totalBallsFaced) * 100 : 0.0;
    double bowlingAverage = totalWickets > 0 ? totalRunsConceded / totalWickets : 0.0;

    return {
      'centuryCount': centuryCount,
      'battingAverage': battingAverage.toStringAsFixed(2),
      'strikeRate': strikeRate.toStringAsFixed(2),
      'inningsPlayed': inningsPlayed,
      'totalWickets': totalWickets,
      'bowlingAverage': bowlingAverage.toStringAsFixed(2),
    };
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateMetrics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cricket Stats Dashboard'),
        backgroundColor: const Color(0xFF161b22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Cricket Stats Dashboard',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: Anonymous',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Career Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMetricCard('Centuries', metrics['centuryCount'].toString(), Colors.blue),
                _buildMetricCard('Batting Average', '${metrics['battingAverage']} (Runs/Innings)', Colors.blue),
                _buildMetricCard('Strike Rate', '${metrics['strikeRate']}%', Colors.blue),
                _buildMetricCard('Total Innings', metrics['inningsPlayed'].toString(), Colors.yellow),
                _buildMetricCard('Total Wickets', metrics['totalWickets'].toString(), Colors.red),
                _buildMetricCard('Bowling Average', '${metrics['bowlingAverage']} (Runs/Wkt)', Colors.pink),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Log New Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _entryNameController,
                        decoration: const InputDecoration(
                          labelText: 'Performance Name (Match/Session)',
                          hintText: 'e.g., Final vs India',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _runsScoredController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Runs Scored',
                              ),
                              validator: (value) {
                                if (value == null || int.tryParse(value) == null || int.parse(value) < 0) {
                                  return 'Must be 0 or greater';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _ballsFacedController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Balls Faced',
                              ),
                              validator: (value) {
                                if (value == null || int.tryParse(value) == null || int.parse(value) < 0) {
                                  return 'Must be 0 or greater';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _wicketsTakenController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Wickets Taken',
                              ),
                              validator: (value) {
                                if (value == null || int.tryParse(value) == null || int.parse(value) < 0) {
                                  return 'Must be 0 or greater';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _runsConcededController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Runs Conceded',
                              ),
                              validator: (value) {
                                if (value == null || int.tryParse(value) == null || int.parse(value) < 0) {
                                  return 'Must be 0 or greater';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addPerformance,
                          child: const Text('Add Performance'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Performance History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_performances.isEmpty)
              const Center(
                child: Text(
                  'No performances logged yet. Use the form above to add your first one!',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _performances.length,
                itemBuilder: (context, index) {
                  final stat = _performances[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.timestamp.toLocal().toString().split(' ')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Runs: ${stat.runsScored} | Balls Faced: ${stat.ballsFaced}',
                            style: const TextStyle(color: Colors.green),
                          ),
                          Text(
                            'Wickets: ${stat.wicketsTaken} | Runs Conceded: ${stat.runsConceded}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
