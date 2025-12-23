import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final StorageService storageService;
  List<Exercise> _exercises = [];
  String _selectedDay = 'Monday';

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  ExerciseProvider(this.storageService);

  List<Exercise> get allExercises => _exercises;
  String get selectedDay => _selectedDay;

  List<Exercise> get exercisesForSelectedDay =>
      _exercises.where((e) => e.dayOfWeek == _selectedDay).toList();

  int get completedExercisesCount =>
      exercisesForSelectedDay.where((e) => e.isCompleted).length;

  int get totalExercisesCount => exercisesForSelectedDay.length;

  Future<void> init() async {
    _exercises = await storageService.getExercises();
    // Seed Monday and Tuesday plans if missing
    final hasMonday = _exercises.any((e) => e.dayOfWeek == 'Monday');
    final hasTuesday = _exercises.any((e) => e.dayOfWeek == 'Tuesday');
    if (!hasMonday) {
      await seedMondayPlan();
    }
    if (!hasTuesday) {
      await seedTuesdayPlan();
    }
    if (!hasMonday || !hasTuesday) {
      _exercises = await storageService.getExercises();
    }
    notifyListeners();
  }

  Future<void> addExercise({
    required String name,
    required String description,
    required String imageUrl,
    required int durationSeconds,
    required String dayOfWeek,
    required String type, // 'warm', 'workout', 'finish'
  }) async {
    const uuid = Uuid();
    final exercise = Exercise(
      id: uuid.v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      durationSeconds: durationSeconds,
      dayOfWeek: dayOfWeek,
      type: type,
    );

    _exercises.add(exercise);
    await storageService.addExercise(exercise);
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      await storageService.updateExercise(exercise);
      notifyListeners();
    }
  }

  Future<void> deleteExercise(String id) async {
    _exercises.removeWhere((e) => e.id == id);
    await storageService.deleteExercise(id);
    notifyListeners();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> markExerciseComplete(
    String id,
    int actualDurationSeconds,
  ) async {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      final ex = _exercises[index];
      ex.isCompleted = true;
      // If the exercise has a target duration (>0), treat the value as seconds.
      if (ex.durationSeconds > 0) {
        ex.actualDurationSeconds = actualDurationSeconds;
      } else {
        // Otherwise treat the value as reps
        ex.actualReps = actualDurationSeconds;
      }
      await updateExercise(ex);
    }
  }

  void resetExerciseProgress(String exerciseId) {
    final exercise = _exercises.cast<Exercise?>().firstWhere(
      (e) => e?.id == exerciseId,
      orElse: () => null,
    );
    if (exercise != null) {
      exercise.isCompleted = false;
      //  exercise.actualDurationSeconds = null;
      //
      //  exercise.actualReps = null;
      notifyListeners();
    }
  }

  Future<void> seedMondayPlan() async {
    // Warm-up
    await addExercise(
      name: 'Jumping jacks',
      description: 'Warm-up — 2 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/jumping_jacks_qygtdk.mp4',
      durationSeconds: 120,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    await addExercise(
      name: 'Arm circles',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411222/Arm_Circles_oey4wi.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    await addExercise(
      name: 'Hip circles',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411226/Hip_Circles_-_Cioffredi_Associates_Physical_Therapy_720p_h264_ajacfc.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    await addExercise(
      name: 'High knees',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/High_Knees_Lv_1_-_FitnessBlender_720p_h264_ynyn81.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    await addExercise(
      name: 'Bodyweight squats',
      description: 'Warm-up — 20 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411230/bodyweight_squats_oqnmfd.webm',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    await addExercise(
      name: 'Easy push-ups',
      description: 'Warm-up — 10 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411226/How_to_do_a_Push-Up_Proper_Form_Technique_NASM_-_National_Academy_of_Sports_Medicine_NASM_720p_h264_ujwwwu.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'warm',
    );

    // Workout (rest 60–90 sec between sets)
    await addExercise(
      name: 'Squats',
      description: 'Workout — 4 × 20 reps. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/squats_cvfajd.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Reverse lunges',
      description: 'Workout — 3 × 15 per leg. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/How_To_Reverse_Lunge_-_PureGym_720p_h264_rr78ze.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Wall sit',
      description: 'Workout — 3 × 60 sec. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411223/Wall_Sit_-_FitnessBlender_720p_h264_y3sv0e.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );
    // Workout (rest 60–90 sec between sets)
    await addExercise(
      name: 'Squats',
      description: 'Workout — 4 × 20 reps. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/squats_cvfajd.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Reverse lunges',
      description: 'Workout — 3 × 15 per leg. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/How_To_Reverse_Lunge_-_PureGym_720p_h264_rr78ze.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Wall sit',
      description: 'Workout — 3 × 60 sec. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411223/Wall_Sit_-_FitnessBlender_720p_h264_y3sv0e.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Push-ups',
      description: 'Workout — 4 × max reps. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411226/How_to_do_a_Push-Up_Proper_Form_Technique_NASM_-_National_Academy_of_Sports_Medicine_NASM_720p_h264_ujwwwu.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Chair dips',
      description: 'Workout — 3 × 15 reps. Rest 60–90 sec between sets',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411235/Chair_Dips_-_BeachCitiesHealth_720p_h264_privce.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Plank',
      description: 'Workout — 3 × 60 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/planks_dgkf8p.webm',
      durationSeconds: 60,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    await addExercise(
      name: 'Mountain climbers',
      description: 'Workout — 3 × 30 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411569/How_to_do_Mountain_Climbers_Correctly____Proper_Exercise_Technique_for_Core_Exercise_-_VIGEO_720p_h264_sbtosf.mp4',
      durationSeconds: 30,
      dayOfWeek: 'Monday',
      type: 'workout',
    );

    // Finisher
    await addExercise(
      name: 'Burpees',
      description: 'Finisher — 3 × 10 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/Burpees_a_powerful_exercise_for_your_homeworkout._More_in_the_link_-_Fit_Media_Channel_720p_h264_wnbrvv.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Monday',
      type: 'finish',
    );
  }

  // Seed Tuesday plan (Cardio, Core, Neck & Posture)
  Future<void> seedTuesdayPlan() async {
    // Cardio
    await addExercise(
      name: 'Brisk walking / fast indoor marching',
      description: 'Cardio — 45–60 min',
      imageUrl: '',
      durationSeconds: 60 * 45,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    // Core (rest 30–45 sec)
    await addExercise(
      name: 'Bicycle crunch',
      description: 'Core — 3 × 20',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766416990/How_To_Do_A_Bicycle_Crunch_shorts_-_Heather_Robertson_720p_h264_v4ww47.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    await addExercise(
      name: 'Leg raises',
      description: 'Core — 3 × 15',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766416953/Leg_Raises_Fitness_Friday_shorts_-_Duke_Health_720p_h264_ndkxse.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    await addExercise(
      name: 'Plank shoulder taps',
      description: 'Core — 3 × 20',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766417002/Shoulder_Taps_Fitness_Friday_shorts_-_Duke_Health_720p_h264_t3ohmq.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    // Neck & Posture
    await addExercise(
      name: 'Chin tucks',
      description: 'Neck & Posture — 3 × 20',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766416953/How_to_do_the_Chin_Tuck_-_BackSpace_Chiropractic_Fitness_TV_720p_h264_hgqez4.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    await addExercise(
      name: 'Wall posture hold',
      description: 'Neck & Posture — 2 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766416951/Wall_Sit_-_FitnessBlender_720p_h264_1_phpv8n.mp4',
      durationSeconds: 120,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );

    await addExercise(
      name: 'Chin lift hold',
      description: 'Neck & Posture — 3 × 30 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766416954/The_Chin_Tuck_Hold_Neck_Strength_Exercise_-_Dr._Carl_Baird_720p_h264_azu91p.mp4',
      durationSeconds: 30,
      dayOfWeek: 'Tuesday',
      type: 'workout',
    );
  }

  Future<void> seedWednesdayPlan() async {
    // Warm-up
    await addExercise(
      name: 'Jumping jacks',
      description: 'Warm-up — 2 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/jumping_jacks_qygtdk.mp4',
      durationSeconds: 120,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );
    await addExercise(
      name: 'Arm circles',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411222/Arm_Circles_oey4wi.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );
    await addExercise(
      name: 'Hip circles',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411226/Hip_Circles_-_Cioffredi_Associates_Physical_Therapy_720p_h264_ajacfc.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );
    await addExercise(
      name: 'High knees',
      description: 'Warm-up — 1 min',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/High_Knees_Lv_1_-_FitnessBlender_720p_h264_ynyn81.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );
    await addExercise(
      name: 'Bodyweight squats',
      description: 'Warm-up — 20 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411230/bodyweight_squats_oqnmfd.webm',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );
    await addExercise(
      name: 'Easy push-ups',
      description: 'Warm-up — 10 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411226/How_to_do_a_Push-Up_Proper_Form_Technique_NASM_-_National_Academy_of_Sports_Medicine_NASM_720p_h264_ujwwwu.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'warm',
    );

    // Workout
    await addExercise(
      name: 'Squats',
      description: 'Workout — 4 × 20 reps',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/squats_cvfajd.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Step-ups (chair)',
      description: 'Workout — 3 × 12 per leg',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505258/Exercise_Tutorial_-_Step_Up_to_Chair_-_XHIT_Daily_1080p_h264_bjiyck.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Wall sit',
      description: 'Workout — 3 × 60 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505249/Wall_Sit_-_FitnessBlender_720p_h264_hof3vi.mp4',
      durationSeconds: 60,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Towel rows',
      description: 'Workout — 4 × 15',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505269/Towel_Rows_-_Side_Quest_Fitness_1080p_h264_znopff.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Towel pull-apart (rear delts)',
      description: 'Workout — 3 × 20',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505256/Rear_Delt_Pull_apart_-_Emmet_Louis_720p_h264_poarpe.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Dead bug',
      description: 'Workout — 3 × 15 per side',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505249/Core_Exercise_Dead_Bug_-_Children_s_Hospital_Colorado_720p_h264_rdeonw.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );
    await addExercise(
      name: 'Plank',
      description: 'Workout — 3 × 60 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411224/planks_dgkf8p.webm',
      durationSeconds: 60,
      dayOfWeek: 'Wednesday',
      type: 'workout',
    );

    // Finisher
    await addExercise(
      name: 'High knees',
      description: 'Finisher — 3 × 45 sec',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766411227/High_Knees_Lv_1_-_FitnessBlender_720p_h264_ynyn81.mp4',
      durationSeconds: 45,
      dayOfWeek: 'Wednesday',
      type: 'finish',
    );
    await addExercise(
      name: 'Jump squats',
      description: 'Finisher — 3 × 20',
      imageUrl:
          'https://res.cloudinary.com/dgztzubdh/video/upload/v1766505251/Squat_Jumps_-_FitnessBlender_1080p_h264_a0piuu.mp4',
      durationSeconds: 0,
      dayOfWeek: 'Wednesday',
      type: 'finish',
    );
  }
}
