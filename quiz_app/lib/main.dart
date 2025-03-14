import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/Question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

/// A simple splash screen that loads the questions from assets.
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = loadQuestions();
  }

  Future<List<Question>> loadQuestions() async {
    final data = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonResult = json.decode(data);
    
    // Parse each item into a Question object.
    final questions = jsonResult.map((q) => Question.fromJson(q)).toList();
    
    // You can shuffle the questions to get them in random order
    questions.shuffle();
    
    // If needed, only take 10 questions (the requirement says "Total 10 questions")
    final firstTen = questions.take(10).toList();
    
    return firstTen;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading questions: ${snapshot.error}')),
          );
        } else {
          final questions = snapshot.data!;
          return QuizPage(questions: questions);
        }
      },
    );
  }
}

/// Main quiz page that shows one question at a time and a 60-second timer
class QuizPage extends StatefulWidget {
  final List<Question> questions;
  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  bool _quizTimeout = false;
  Timer? _timer;
  int _timeLeft = 60; // 60-second timer

  // This will store the user's selected answers for multiple selection questions
  // Key: question index, Value: Set of selected option indices
  Map<int, Set<int>> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _quizTimeout = true;
          timer.cancel();
        }
      });
    });
  }

  void _submitAndNext() {
    // If time is out, do nothing (the user won't get any score anyway).
    if (_quizTimeout) {
      // Optionally push them to results screen automatically
      if (_currentIndex < widget.questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _showResults();
      }
      return;
    }

    // Check the user's selection for the current question
    final question = widget.questions[_currentIndex];
    final userSelectedIndices = _userSelections[_currentIndex] ?? {};

    // Scoring logic
    // "single": If exactly 1 correct index selected, and it matches question.correctAnswers.
    // "true_false": same logic as single
    // "multiple": Must match the entire set of correct answers exactly
    bool correct = false;

    if (question.type == 'single' || question.type == 'true_false') {
      // Expect exactly 1 selected answer
      if (userSelectedIndices.length == 1) {
        final selectedIndex = userSelectedIndices.first;
        if (question.correctAnswers.length == 1 &&
            question.correctAnswers.first == selectedIndex) {
          correct = true;
        }
      }
    } else if (question.type == 'multiple') {
      // Must match the entire set
      final correctSet = question.correctAnswers.toSet();
      if (correctSet.length == userSelectedIndices.length &&
          correctSet.containsAll(userSelectedIndices)) {
        correct = true;
      }
    }

    if (correct) {
      _score++;
    }

    // Move to the next question or show results
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // If the user timed out, the score is 0.
    // Or if you want to say "no score if quiz times out" – that might mean we simply pass 0 to ResultsPage.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          score: _quizTimeout ? 0 : _score,
          total: widget.questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];

    // If we haven't stored a selection set for this question, initialize it
    _userSelections.putIfAbsent(_currentIndex, () => {});

    if (_quizTimeout) {
      // Optional: show a "Time is up" message and let user continue
      // or just skip directly to the results. Here we let them see "time out" but can still continue
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz - TIME OUT'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _showResults,
            child: const Text('Time is up! See Results'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${widget.questions.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Time: $_timeLeft s'),
            ),
          ),
        ],
      ),
      body: _buildQuestionWidget(question),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _submitAndNext,
          child: Text(
            _currentIndex < widget.questions.length - 1
              ? 'Submit & Next'
              : 'Submit & Finish',
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case 'true_false':
      case 'single':
        return _buildSingleChoiceQuestion(question);
      case 'multiple':
        return _buildMultipleChoiceQuestion(question);
      default:
        return const Center(child: Text('Unknown question type.'));
    }
  }

  Widget _buildSingleChoiceQuestion(Question question) {
    final selectedIndices = _userSelections[_currentIndex]!;
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(question.questionText, style: const TextStyle(fontSize: 20)),
        ),
        ...List.generate(question.options.length, (index) {
          return RadioListTile<int>(
            title: Text(question.options[index]),
            value: index,
            groupValue: selectedIndices.isEmpty ? null : selectedIndices.first,
            onChanged: (val) {
              setState(() {
                selectedIndices.clear();
                selectedIndices.add(val!);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Question question) {
    final selectedIndices = _userSelections[_currentIndex]!;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(question.questionText, style: const TextStyle(fontSize: 20)),
        ),
        ...List.generate(question.options.length, (index) {
          return CheckboxListTile(
            title: Text(question.options[index]),
            value: selectedIndices.contains(index),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedIndices.add(index);
                } else {
                  selectedIndices.remove(index);
                }
              });
            },
          );
        }),
      ],
    );
  }
}

/// Results page that shows final score
class ResultsPage extends StatelessWidget {
  final int score;
  final int total;
  const ResultsPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: Center(
        child: Text(
          'Your Score: $score / $total',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}