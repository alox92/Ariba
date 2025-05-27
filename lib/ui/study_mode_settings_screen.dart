import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';

class StudyModeSettingsScreen extends StatefulWidget {
  const StudyModeSettingsScreen({super.key});

  @override
  State<StudyModeSettingsScreen> createState() => _StudyModeSettingsScreenState();
}

class _StudyModeSettingsScreenState extends State<StudyModeSettingsScreen> {
  // Quiz Mode Settings
  int _quizQuestionsCount = 20;
  bool _quizRandomizeOptions = true;
  bool _quizShowHints = true;
  
  // Speed Round Settings
  int _speedRoundDuration = 60;
  bool _speedRoundSoundEffects = true;
  int _speedRoundDifficulty = 2; // 1=Easy, 2=Medium, 3=Hard
  
  // Writing Practice Settings
  bool _writingAllowTypos = true;
  bool _writingShowHints = true;
  int _writingMaxHints = 3;
  
  // Matching Game Settings
  int _matchingGameSize = 8; // Number of pairs
  bool _matchingTimerEnabled = true;
  int _matchingTimeLimit = 300; // 5 minutes
  
  // General Settings
  bool _enableVibration = true;
  bool _enableSoundEffects = true;
  bool _enableAnimations = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Quiz settings
      _quizQuestionsCount = prefs.getInt('quiz_questions_count') ?? 20;
      _quizRandomizeOptions = prefs.getBool('quiz_randomize_options') ?? true;
      _quizShowHints = prefs.getBool('quiz_show_hints') ?? true;
      
      // Speed round settings
      _speedRoundDuration = prefs.getInt('speed_round_duration') ?? 60;
      _speedRoundSoundEffects = prefs.getBool('speed_round_sound_effects') ?? true;
      _speedRoundDifficulty = prefs.getInt('speed_round_difficulty') ?? 2;
      
      // Writing practice settings
      _writingAllowTypos = prefs.getBool('writing_allow_typos') ?? true;
      _writingShowHints = prefs.getBool('writing_show_hints') ?? true;
      _writingMaxHints = prefs.getInt('writing_max_hints') ?? 3;
      
      // Matching game settings
      _matchingGameSize = prefs.getInt('matching_game_size') ?? 8;
      _matchingTimerEnabled = prefs.getBool('matching_timer_enabled') ?? true;
      _matchingTimeLimit = prefs.getInt('matching_time_limit') ?? 300;
      
      // General settings
      _enableVibration = prefs.getBool('enable_vibration') ?? true;
      _enableSoundEffects = prefs.getBool('enable_sound_effects') ?? true;
      _enableAnimations = prefs.getBool('enable_animations') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save quiz settings
    await prefs.setInt('quiz_questions_count', _quizQuestionsCount);
    await prefs.setBool('quiz_randomize_options', _quizRandomizeOptions);
    await prefs.setBool('quiz_show_hints', _quizShowHints);
    
    // Save speed round settings
    await prefs.setInt('speed_round_duration', _speedRoundDuration);
    await prefs.setBool('speed_round_sound_effects', _speedRoundSoundEffects);
    await prefs.setInt('speed_round_difficulty', _speedRoundDifficulty);
    
    // Save writing practice settings
    await prefs.setBool('writing_allow_typos', _writingAllowTypos);
    await prefs.setBool('writing_show_hints', _writingShowHints);
    await prefs.setInt('writing_max_hints', _writingMaxHints);
    
    // Save matching game settings
    await prefs.setInt('matching_game_size', _matchingGameSize);
    await prefs.setBool('matching_timer_enabled', _matchingTimerEnabled);
    await prefs.setInt('matching_time_limit', _matchingTimeLimit);
    
    // Save general settings
    await prefs.setBool('enable_vibration', _enableVibration);
    await prefs.setBool('enable_sound_effects', _enableSoundEffects);
    await prefs.setBool('enable_animations', _enableAnimations);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Mode Settings'),
          actions: [
            IconButton(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              tooltip: 'Save Settings',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGeneralSettings(),
              const SizedBox(height: 32),
              _buildQuizSettings(),
              const SizedBox(height: 32),
              _buildSpeedRoundSettings(),
              const SizedBox(height: 32),
              _buildWritingPracticeSettings(),
              const SizedBox(height: 32),
              _buildMatchingGameSettings(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return _buildSettingsSection(
      'General Settings',
      Icons.settings,
      [
        SwitchListTile(
          title: const Text('Enable Vibration'),
          subtitle: const Text('Haptic feedback for interactions'),
          value: _enableVibration,
          onChanged: (value) => setState(() => _enableVibration = value),
        ),
        SwitchListTile(
          title: const Text('Enable Sound Effects'),
          subtitle: const Text('Audio feedback for correct/incorrect answers'),
          value: _enableSoundEffects,
          onChanged: (value) => setState(() => _enableSoundEffects = value),
        ),
        SwitchListTile(
          title: const Text('Enable Animations'),
          subtitle: const Text('Visual animations and transitions'),
          value: _enableAnimations,
          onChanged: (value) => setState(() => _enableAnimations = value),
        ),
      ],
    );
  }

  Widget _buildQuizSettings() {
    return _buildSettingsSection(
      'Quiz Mode',
      Icons.quiz,
      [
        ListTile(
          title: const Text('Number of Questions'),
          subtitle: Text('$_quizQuestionsCount questions per quiz'),
          trailing: DropdownButton<int>(
            value: _quizQuestionsCount,
            items: [10, 15, 20, 25, 30].map((count) {
              return DropdownMenuItem(
                value: count,
                child: Text('$count'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _quizQuestionsCount = value ?? 20),
          ),
        ),
        SwitchListTile(
          title: const Text('Randomize Answer Options'),
          subtitle: const Text('Shuffle multiple choice options'),
          value: _quizRandomizeOptions,
          onChanged: (value) => setState(() => _quizRandomizeOptions = value),
        ),
        SwitchListTile(
          title: const Text('Show Hints'),
          subtitle: const Text('Display hints for difficult questions'),
          value: _quizShowHints,
          onChanged: (value) => setState(() => _quizShowHints = value),
        ),
      ],
    );
  }

  Widget _buildSpeedRoundSettings() {
    return _buildSettingsSection(
      'Speed Round',
      Icons.flash_on,
      [
        ListTile(
          title: const Text('Round Duration'),
          subtitle: Text('$_speedRoundDuration seconds'),
          trailing: DropdownButton<int>(
            value: _speedRoundDuration,
            items: [30, 45, 60, 90, 120].map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text('${duration}s'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _speedRoundDuration = value ?? 60),
          ),
        ),
        ListTile(
          title: const Text('Difficulty Level'),
          subtitle: Text(_getDifficultyText(_speedRoundDifficulty)),
          trailing: DropdownButton<int>(
            value: _speedRoundDifficulty,
            items: [
              const DropdownMenuItem(value: 1, child: Text('Easy')),
              const DropdownMenuItem(value: 2, child: Text('Medium')),
              const DropdownMenuItem(value: 3, child: Text('Hard')),
            ],
            onChanged: (value) => setState(() => _speedRoundDifficulty = value ?? 2),
          ),
        ),
        SwitchListTile(
          title: const Text('Sound Effects'),
          subtitle: const Text('Audio cues for correct/incorrect answers'),
          value: _speedRoundSoundEffects,
          onChanged: (value) => setState(() => _speedRoundSoundEffects = value),
        ),
      ],
    );
  }

  Widget _buildWritingPracticeSettings() {
    return _buildSettingsSection(
      'Writing Practice',
      Icons.edit,
      [
        SwitchListTile(
          title: const Text('Allow Minor Typos'),
          subtitle: const Text('Accept answers with small spelling mistakes'),
          value: _writingAllowTypos,
          onChanged: (value) => setState(() => _writingAllowTypos = value),
        ),
        SwitchListTile(
          title: const Text('Show Hints'),
          subtitle: const Text('Provide hints for difficult answers'),
          value: _writingShowHints,
          onChanged: (value) => setState(() => _writingShowHints = value),
        ),
        if (_writingShowHints)
          ListTile(
            title: const Text('Maximum Hints'),
            subtitle: Text('Up to $_writingMaxHints hints per question'),
            trailing: DropdownButton<int>(
              value: _writingMaxHints,
              items: [1, 2, 3, 4, 5].map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text('$count'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _writingMaxHints = value ?? 3),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchingGameSettings() {
    return _buildSettingsSection(
      'Matching Game',
      Icons.gamepad,
      [
        ListTile(
          title: const Text('Game Size'),
          subtitle: Text('$_matchingGameSize pairs to match'),
          trailing: DropdownButton<int>(
            value: _matchingGameSize,
            items: [6, 8, 10, 12].map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text('$size pairs'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _matchingGameSize = value ?? 8),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Timer'),
          subtitle: const Text('Add time pressure to the game'),
          value: _matchingTimerEnabled,
          onChanged: (value) => setState(() => _matchingTimerEnabled = value),
        ),
        if (_matchingTimerEnabled)
          ListTile(
            title: const Text('Time Limit'),
            subtitle: Text('${_matchingTimeLimit ~/ 60} minutes'),
            trailing: DropdownButton<int>(
              value: _matchingTimeLimit,
              items: [180, 240, 300, 360, 420].map((seconds) {
                return DropdownMenuItem(
                  value: seconds,
                  child: Text('${seconds ~/ 60} min'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _matchingTimeLimit = value ?? 300),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy - More time per question';
      case 2:
        return 'Medium - Balanced gameplay';
      case 3:
        return 'Hard - Quick responses required';
      default:
        return 'Medium';
    }
  }
}
