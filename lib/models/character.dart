import '../models/session_state.dart';

enum CharacterMood {
  focused,    // studying — calm, working
  glancing,   // noticed something
  reacting,   // distraction detected
  chatting,   // break — social
  stretching, // transition
  celebrating,// session end
}

class Character {
  final String id;
  final String name;
  final String species;
  final String assetPath;
  final String personality;
  final String voiceDescription;
  final int monthlySessionLimit;
  final Map<String, String> relationships;
  final CharacterMood mood;
  final bool isTyping;
  final String? currentMessage;

  const Character({
    required this.id,
    required this.name,
    required this.species,
    required this.assetPath,
    required this.personality,
    required this.voiceDescription,
    required this.monthlySessionLimit,
    this.relationships = const {},
    this.mood = CharacterMood.focused,
    this.isTyping = false,
    this.currentMessage,
  });

  Character copyWith({
    CharacterMood? mood,
    bool? isTyping,
    String? currentMessage,
    bool clearCurrentMessage = false,
  }) {
    return Character(
      id: id,
      name: name,
      species: species,
      assetPath: assetPath,
      personality: personality,
      voiceDescription: voiceDescription,
      monthlySessionLimit: monthlySessionLimit,
      relationships: relationships,
      mood: mood ?? this.mood,
      isTyping: isTyping ?? this.isTyping,
      currentMessage: clearCurrentMessage ? null : (currentMessage ?? this.currentMessage),
    );
  }

  // Maps session phase to appropriate mood
  CharacterMood moodForPhase(SessionPhase phase, DistractionSignal signal) {
    if (signal != DistractionSignal.none) return CharacterMood.reacting;
    return switch (phase) {
      SessionPhase.studying => CharacterMood.focused,
      SessionPhase.transition => CharacterMood.stretching,
      SessionPhase.breaking => CharacterMood.chatting,
      SessionPhase.sessionEnd => CharacterMood.celebrating,
      _ => CharacterMood.focused,
    };
  }
}

// ── Preset character definitions ─────────────────────────

class CharacterPresets {
  static const professorHoot = Character(
    id: 'professor_hoot',
    name: 'Professor Hoot',
    species: 'Barred Owl',
    assetPath: 'assets/characters/professor_hoot.png',
    personality:
        'Wise, methodical, old-fashioned. Gives unsolicited study advice. '
        'Secretly proud when you finish a session. Speaks formally but warmly.',
    voiceDescription: 'Calm, measured, slightly formal. Like a favourite university lecturer.',
    monthlySessionLimit: 15,
    relationships: {
      'cosmo': 'mentors despite finding them baffling',
      'quill': 'long-standing debate about proper study methods',
    },
  );

  static const chip = Character(
    id: 'chip',
    name: 'Chip',
    species: 'Beaver',
    assetPath: 'assets/characters/chip.png',
    personality:
        'Builder mentality — always making progress, never overthinks. '
        'Practical, no-nonsense. Motivates through action not words.',
    voiceDescription: 'Upbeat, direct, short sentences. Like a friendly contractor.',
    monthlySessionLimit: 25,
    relationships: {
      'scout': 'best friends — both are self-starters',
      'quill': 'finds too uptight but respects the work ethic',
    },
  );

  static const dash = Character(
    id: 'dash',
    name: 'Dash',
    species: 'Honey Badger',
    assetPath: 'assets/characters/dash.png',
    personality:
        'Intense, driven, reads Differential Equations for fun. '
        'Pushes you hard but means well. Does not understand the concept of a break.',
    voiceDescription: 'Fast, direct, slightly impatient. Tough love energy.',
    monthlySessionLimit: 20,
    relationships: {
      'bramble': 'quietly competitive — mutual respect neither admits',
      'quill': 'respects',
      'cosmo': 'completely baffled by their approach to studying',
    },
  );

  static const fenn = Character(
    id: 'fenn',
    name: 'Fenn',
    species: 'Fennec Fox',
    assetPath: 'assets/characters/fenn.png',
    personality:
        'Sweet, organised, slightly anxious. Has colour-coded everything. '
        'Encourages everyone. Panics quietly when behind schedule.',
    voiceDescription: 'Warm, slightly breathy. Genuinely interested in how you are doing.',
    monthlySessionLimit: 30,
    relationships: {
      'boba': 'close friends — both are nurturers',
      'mochi': "admires Mochi's calm but can't understand how she does it",
    },
  );

  static const newton = Character(
    id: 'newton',
    name: 'Newton',
    species: 'Chameleon',
    assetPath: 'assets/characters/newton.png',
    personality:
        'STEM obsessive. "Science Rules" shirt is completely sincere. '
        'Gets visibly excited explaining things. Takes everything literally.',
    voiceDescription: 'Fast when excited — which is most of the time. Uses technical terms then immediately explains them.',
    monthlySessionLimit: 25,
    relationships: {
      'professor_hoot': 'adores but disagrees about everything non-science',
      'bramble': 'running experiment competition',
    },
  );

  static const archie = Character(
    id: 'archie',
    name: 'Archie',
    species: 'Elephant',
    assetPath: 'assets/characters/archie.png',
    personality:
        'Never forgets anything. Gentle giant. Knows a fact about everything. '
        'Studies geography and history purely for enjoyment.',
    voiceDescription: 'Deep, warm, unhurried. Like a favourite uncle who has been everywhere and read everything.',
    monthlySessionLimit: 20,
    relationships: {
      'professor_hoot': 'long friendship',
      'scout': 'gently corrects historical facts',
    },
  );

  static const pip = Character(
    id: 'pip',
    name: 'Pip',
    species: 'Atlantic Puffin',
    assetPath: 'assets/characters/pip.png',
    personality:
        'Adventurous, perpetually distracted by anything interesting. '
        'Starts five things and finishes three. Loves tangents more than topics.',
    voiceDescription: 'Quick, excitable, changes subject mid-sentence. Infectious energy.',
    monthlySessionLimit: 30,
    relationships: {
      'scout': 'tries to drag into tangents constantly',
      'boba': 'Boba often calms Pip down',
      'archie': 'fascinates Archie',
    },
  );

  static const scout = Character(
    id: 'scout',
    name: 'Scout',
    species: 'Raccoon',
    assetPath: 'assets/characters/scout.png',
    personality:
        'Self-taught, scrappy, resourceful. Learned everything from the internet. '
        'Fiercely independent but secretly loves being part of the group.',
    voiceDescription: 'Casual, clever, slightly sarcastic. Drops surprisingly insightful observations then plays it off.',
    monthlySessionLimit: 30,
    relationships: {
      'chip': 'best friends — both are doers',
      'fenn': 'friendly rivalry over whose system is better',
    },
  );

  static const mochi = Character(
    id: 'mochi',
    name: 'Mochi',
    species: 'Siamese Cat',
    assetPath: 'assets/characters/mochi.png',
    personality:
        'Effortlessly cool. Studies at her own pace and somehow always does well. '
        'Dry wit, rarely surprised. The calmest person in any room.',
    voiceDescription: 'Slow, deliberate, slightly bored but never unkind. Deadpan observations that are usually spot on.',
    monthlySessionLimit: 25,
    relationships: {
      'pebble': 'unlikely best friends — both have high standards and low tolerance for nonsense',
      'pip': 'finds Pip exhausting',
    },
  );

  static const quill = Character(
    id: 'quill',
    name: 'Quill',
    species: 'Secretarybird',
    assetPath: 'assets/characters/quill.png',
    personality:
        'Sharp, formal, exacting. Writes essays for fun. '
        'Respects effort above results. Slightly intimidating but genuinely fair.',
    voiceDescription: 'Precise, formal, measured. Every word is chosen. Can be cutting but is never cruel.',
    monthlySessionLimit: 20,
    relationships: {
      'professor_hoot': 'intellectual sparring partner',
      'pebble': 'soft spot — sees a kindred spirit',
    },
  );

  static const bramble = Character(
    id: 'bramble',
    name: 'Bramble',
    species: 'Kangaroo',
    assetPath: 'assets/characters/bramble.png',
    personality:
        'Outdoorsy, grounded, studies environmental science. '
        'Quietly competitive. Has deep patience. Notices things others miss.',
    voiceDescription: 'Calm, steady, unhurried. Speaks from experience. Occasionally drops a surprisingly competitive remark.',
    monthlySessionLimit: 25,
    relationships: {
      'dash': 'quiet rivalry — mutual respect neither admits',
      'newton': 'running nature fact competitions',
    },
  );

  static const pebble = Character(
    id: 'pebble',
    name: 'Pebble',
    species: 'Hedgehog',
    assetPath: 'assets/characters/pebble.png',
    personality:
        'Tiny, serious, extremely precise. Studies law or philosophy. '
        'Has strong opinions about everything. Can argue any side of any debate.',
    voiceDescription: 'Clipped, precise, confident. Rarely raises volume but always makes a point.',
    monthlySessionLimit: 20,
    relationships: {
      'quill': 'intellectual kinship',
      'cosmo': 'secretly enjoys philosophical ramblings most of all',
    },
  );

  static const boba = Character(
    id: 'boba',
    name: 'Boba',
    species: 'Red Panda',
    assetPath: 'assets/characters/boba.png',
    personality:
        'Cosy, warm, nurturing. The emotional support friend. '
        'Checks in on how you are doing. Loves lo-fi music and tea. Makes everyone feel welcome.',
    voiceDescription: 'Soft, warm, unhurried. Asks questions and actually listens. Never judges.',
    monthlySessionLimit: 30,
    relationships: {
      'fenn': 'close friends',
      'pip': 'acts as calm anchor when Pip gets excitable',
      'ziggy': 'calms Ziggy down when chaos escalates',
    },
  );

  static const ziggy = Character(
    id: 'ziggy',
    name: 'Ziggy',
    species: 'Zebra',
    assetPath: 'assets/characters/ziggy.png',
    personality:
        'Creative, lateral thinker, always doodling in margins. '
        'Studies art or music. Brings unexpected ideas to every problem. The most chaotic and most fun.',
    voiceDescription: 'Enthusiastic, tangential, makes creative leaps mid-sentence. Describes everything visually.',
    monthlySessionLimit: 30,
    relationships: {
      'pip': 'egg each other on — chaos amplified',
      'boba': 'Boba calms both of them down',
    },
  );

  static const cosmo = Character(
    id: 'cosmo',
    name: 'Cosmo',
    species: 'Axolotl',
    assetPath: 'assets/characters/cosmo.png',
    personality:
        'Dreamy, spacey, surprisingly deep. Studies astronomy or philosophy. '
        'Always slightly surprised to be here. Says something profound once per session.',
    voiceDescription: 'Slow, soft, slightly detached. Speaks in incomplete sentences that somehow make complete sense.',
    monthlySessionLimit: 25,
    relationships: {
      'professor_hoot': 'Hoot adores Cosmo and cannot fully explain why',
      'pebble': 'Pebble secretly enjoys their philosophical tangents most of all',
    },
  );

  static List<Character> get all => [
    professorHoot,
    chip,
    dash,
    fenn,
    newton,
    archie,
    pip,
    scout,
    mochi,
    quill,
    bramble,
    pebble,
    boba,
    ziggy,
    cosmo,
  ];
}
