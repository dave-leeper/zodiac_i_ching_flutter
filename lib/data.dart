part of 'main.dart';

class TrigramInfo {
  String symbol, name, earlier, later, zodiac;
  TrigramInfo(this.symbol, this.name, this.earlier, this.later, this.zodiac);
  String fullTitle() {
    return '$symbol $name (Earlier Heaven: $earlier, Later Heaven: $later)';
  }
}

class PlanetInfo {
  String symbol, name;
  PlanetInfo(this.symbol, this.name);
}

class ZodiacInfo {
  String symbol, name, domicile, detriment, exalted, fall, time, element;
  ZodiacInfo(this.symbol, this.name, this.domicile, this.detriment, this.exalted, this.fall, this.time, this.element);
  String fullTitle() {
    var timeString = times[time]?.name;
    var elementString = elements[element]?.represents;
    timeString ??= Time('?', 'Unknown').name;
    elementString ??= Element('?', 'Unknown', 'Unknown', {}).represents;

    return '$symbol $name (${timeEnergy()})';
  }

  String timeEnergy() {
    var timeString = times[time]?.name;
    var elementString = elements[element]?.represents;
    timeString ??= Time('?', 'Unknown').name;
    elementString ??= Element('?', 'Unknown', 'Unknown', {}).represents;

    return '$timeString $elementString';
  }

  String planetDetails() {
    return 'Domicile: $domicile Exalted: $exalted Detriment: $detriment Fall: $fall';
  }
}

class IChingInfo {
  int number;
  String name, meaning, commentary, externalTrigram, internalTrigram;
  IChingInfo(this.number, this.name, this.meaning, this.commentary, this.externalTrigram, this.internalTrigram);
  TrigramInfo externaTrigram() {
    var extTrigram = trigrams[externalTrigram];
    extTrigram ??= TrigramInfo('?', 'Unknown', '?', '', '?');
    return extTrigram;
  }

  TrigramInfo internaTrigram() {
    var intTrigram = trigrams[internalTrigram];
    intTrigram ??= TrigramInfo('?', 'Unknown', '?', '', '?');
    return intTrigram;
  }

  ZodiacInfo externalZodiac() {
    var extTrigram = trigrams[externalTrigram];
    var extZodiac = zodiac[extTrigram?.zodiac];
    extZodiac ??= ZodiacInfo('?', 'Unknown', '?', '', '?', '?', '?', '?');
    return extZodiac;
  }

  ZodiacInfo internalZodiac() {
    var intTrigram = trigrams[internalTrigram];
    var intZodiac = zodiac[intTrigram?.zodiac];
    intZodiac ??= ZodiacInfo('?', 'Unknown', '?', '', '?', '?', '?', '?');
    return intZodiac;
  }
}

class CourtCard {
  String externalSymbol, internalSymbol, imagePath, name;
  CourtCard(this.externalSymbol, this.internalSymbol, this.imagePath, this.name);
}

class ElementTransform {
  String transform, name, description;
  ElementTransform(this.transform, this.name, this.description);
}

class ElementTransformTo {
  String to, transform;
  ElementTransformTo(this.to, this.transform);
}

class Element {
  final String symbol, name, represents;
  Map<String, ElementTransformTo> transforms;
  Element(this.symbol, this.name, this.represents, this.transforms);
}

class Time {
  final String symbol, name;
  Time(this.symbol, this.name);
}

final fireTrigrams = <String>['☲', '⚎', '☳'];
final waterTrigrams = <String>['☵', '⚍', '☴'];
final airTrigrams = <String>['☰', '⚌', '☱'];
final earthTrigrams = <String>['☷', '⚏', '☶'];
final loShuGrouping = <List>[fireTrigrams, waterTrigrams, airTrigrams, earthTrigrams];
final trigrams = {
  "☰": TrigramInfo("☰", "Heaven", "South", "Northwest", "♊︎"),
  "☱": TrigramInfo("☱", "Lake", "Southeast", "West", "♎︎"),
  "☲": TrigramInfo("☲", "Fire", "East", "South", "♐︎"),
  "☳": TrigramInfo("☳", "Thunder", "Northeast", "East", "♈︎"),
  "☴": TrigramInfo("☴", "Wind", "Southwest", "Southeast", "♋︎"),
  "☵": TrigramInfo("☵", "Water", "West", "North", "♓︎"),
  "☶": TrigramInfo("☶", "Mountain", "Northwest", "Northeast", "♑︎"),
  "☷": TrigramInfo("☷", "Earth", "North", "Southwest", "♍︎"),
  "⚎": TrigramInfo("⚎", "Lesser Yang", "None", "None", "♌︎"),
  "⚌": TrigramInfo("⚌", "Greater Yang", "None", "None", "♒︎"),
  "⚍": TrigramInfo("⚍", "Lesser Yin", "None", "None", "♏︎"),
  "⚏": TrigramInfo("⚏", "Greater Yin", "None", "None", "♉︎")
};
final planets = {
  "☉": PlanetInfo("☉", "Sun"),
  "☽︎": PlanetInfo("☽︎", "Moon"),
  "☿": PlanetInfo("☿", "Mercury"),
  "♀": PlanetInfo("♀", "Venus"),
  "♂": PlanetInfo("♂", "Mars"),
  "♃": PlanetInfo("♃", "Jupiter"),
  "♄": PlanetInfo("♄", "Saturn"),
  "♆": PlanetInfo("♆", "Neptune"),
  "♅": PlanetInfo("♅", "Uranus"),
  "♇": PlanetInfo("♇", "Pluto")
};
final zodiac = {
  "♈︎": ZodiacInfo("♈︎", "Aries", "♂", "♀", "☉", "♄", ">", "🜂"),
  "♉︎": ZodiacInfo("♉︎", "Taurus", "♀", "♂", "☽︎", "♅", "-", "🜃"),
  "♊︎": ZodiacInfo("♊︎", "Gemini", "☿", "♃", "None", "None", "<", "🜁"),
  "♋︎": ZodiacInfo("♋︎", "Cancer", "☽︎", "♄", "♃", "♂", ">", "🜄"),
  "♌︎": ZodiacInfo("♌︎", "Leo", "☉", "♄", "None", "♇", "-", "🜂"),
  "♍︎": ZodiacInfo("♍︎", "Virgo", "☿", "♃", "☿", "♀", "<", "🜃"),
  "♎︎": ZodiacInfo("♎︎", "Libra", "♀", "♂", "♄", "☉", ">", "🜁"),
  "♏︎": ZodiacInfo("♏︎", "Scorpio", "♂♇", "None", "None", "☽︎", "-", "🜄"),
  "♐︎": ZodiacInfo("♐︎", "Sagittarius", "♃", "☿", "None", "☽", "<", "🜂"),
  "♑︎": ZodiacInfo("♑︎", "Capricorn", "♄", "☽︎", "♂", "♃", ">", "🜃"),
  "♒︎": ZodiacInfo("♒︎", "Aquarius", "♄♅", "☉", "None", "None", "-", "🜁"),
  "♓︎": ZodiacInfo("♓︎", "Pisces", "♃♆", "☿", "♀", "☿", "<", "🜄"),
};
final iChing = <IChingInfo>[
  IChingInfo(1, "The Creative", "Possessing creative power and skill.", "The Creative is Gemini externally and internally. Gemini, Past Thought, is home to Mercury, the Logos.", "☰", "☰"),
  IChingInfo(2, "The Receptive", "Needing knowledge and skill. Do not force matters and go with the flow.",
      "The Receptive is Virgo enternally and internally. Virgo, Past World, is home to Mercury, the Logos. Heaven and Earth, while different from one another, share a certain nature.", "☷", "☷"),
  IChingInfo(3, "Difficulty", "Sprouting", "New work is started, but success is not certain.", "☵", "☳"),
  IChingInfo(4, "Innocence", "Detained, enveloped, and inexperienced.", "The world does not work the way you believe it does.", "☶", "☵"),
  IChingInfo(5, "Waiting", "Uninvolved (waiting for now), nourishment.", "New problems can be dealt with by waiting.", "☵", "☰"),
  IChingInfo(6, "Contention", "Engagement in conflict.", "New problems cause contention, seek wisdom.", "☰", "☵"),
  IChingInfo(7, "An Army", "Bringing together. Teamwork.", "This is patriotism. An army that has succeeded is passive.", "☷", "☵"),
  IChingInfo(8, "Accord", "Union", "There is accord.", "☵", "☷"),
  IChingInfo(9, "Nurture of the Small", "Accumulating resources.", "Take advantage of new relationships.", "☴", "☰"),
  IChingInfo(10, "Treading", "Continuing with alertness.", "Resistance is slight, but stay mindful.", "☰", "☱"),
  IChingInfo(11, "Tranquillity", "Prevading.", "This is tranquillity.", "☷", "☰"),
  IChingInfo(12, "Obstruction", "Stagnation.", "This is stagnation.", "☰", "☷"),
  IChingInfo(13, "Sameness With People", "Fellowship. Partnership.", "Actions match the thoughts of the people, which is sameness.", "☰", "☲"),
  IChingInfo(14, "Great Possession", "Independance. Freedom.", "There is no resistance to your goals.", "☲", "☰"),
  IChingInfo(15, "Humility", "Being reserved, refraining.", "Show respect and there is success.", "☷", "☶"),
  IChingInfo(16, "Happiness", "Inducement, new stimulus.", "New experiences bring happiness.", "☳", "☷"),
  IChingInfo(17, "Following", "Following.", "The people believe in what you do.", "☱", "☳"),
  IChingInfo(18, "Disruption", "Repairing.", "The old ways slip away.", "☶", "☴"),
  IChingInfo(19, "Overseeing", "Approching goal, arriving.", "Bringing change requires careful management.", "☷", "☱"),
  IChingInfo(20, "Observing", "The Withholding.", "The sacred is held on high.", "☴", "☷"),
  IChingInfo(21, "Biting Through", "Deciding.", "With care, there is success.", "☲", "☳"),
  IChingInfo(22, "Adornment", "Embellishing.", "Acceptance of the new in terms of the past.", "☶", "☲"),
  IChingInfo(23, "Stripping Away", "Stripping, flaying.", "The stylish is valued by the people over the classic.", "☶", "☷"),
  IChingInfo(24, "Return", "Returning.", "With care, strength can grow.", "☷", "☳"),
  IChingInfo(25, "Fidelity", "Without rashness.", "If you are right, the people will follow.", "☰", "☳"),
  IChingInfo(26, "Great Buildup", "Accumulating wisdom.", "Opprotunities to learn.", "☶", "☰"),
  IChingInfo(27, "Nourishment", "Seeking nourishment.", "The world supplies what you need.", "☶", "☳"),
  IChingInfo(28, "Predominance of the Great", "Great surpassing.", "Exciting plans.", "☱", "☴"),
  IChingInfo(29, "Constant Pitfalls", "Darkness. Gorge.", "The ability to handle new problems is weak.", "☵", "☵"),
  IChingInfo(30, "Fire", "Clinging. Attachment.", "The fire still burns.", "☲", "☲"),
  IChingInfo(31, "Sensitivity", "Attraction.", "Take care and success follows.", "☱", "☶"),
  IChingInfo(32, "Persistence", "Constancy.", "Believe in what is being done.", "☳", "☴"),
  IChingInfo(33, "Withdrawal", "Withdrawing.", "Secrecy may be needed.", "☰", "☶"),
  IChingInfo(34, "The Power of Greatness", "Great boldness.", "Calmness in a dynamic situation.", "☳", "☰"),
  IChingInfo(35, "Advance", "Expansion, promotion.", "Tried and true methods, tried and true results.", "☲", "☷"),
  IChingInfo(36, "Injury to the Enlightened", "Brilliance injured.", "In an environment that doesn't change, you must do the work yourself.", "☷", "☲"),
  IChingInfo(37, "People in the Home", "Family.", "With an eye to the future, the family members carry out their duties.", "☴", "☲"),
  IChingInfo(38, "Opposition", "Division, divergence.", "This is opposition.", "☲", "☱"),
  IChingInfo(39, "Halting", "Trouble, hardship.", "The people do not embrace to new.", "☵", "☶"),
  IChingInfo(40, "Solution", "Liberation, solution.", "FDoing something new to move beyond past feelings.", "☳", "☵"),
  IChingInfo(41, "Reduction", "Decrease.", "Reducing the old to build the new.", "☶", "☱"),
  IChingInfo(42, "Increase", "Increase.", "The people support what you do.", "☴", "☳"),
  IChingInfo(43, "Decisiveness", "Seperation.", "Using limited information to navigate a new situation.", "☱", "☰"),
  IChingInfo(44, "Meeting", "Encountering.", "Understand the other's intensions.", "☰", "☴"),
  IChingInfo(45, "Gathering", "Association, companionship.", "Listen and benefit.", "☱", "☷"),
  IChingInfo(46, "Rising", "Growing upward.", "Opprotunity for growth.", "☷", "☴"),
  IChingInfo(47, "Exhaustion", "Exhaustion.", "Holding on without support is exhausting.", "☱", "☵"),
  IChingInfo(48, "The Well", "Replenishment, renewal.", "Emotion alone may not be enough.", "☵", "☴"),
  IChingInfo(49, "Change", "Abolishing the old.", "The people want something you may not believe in.", "☱", "☲"),
  IChingInfo(50, "The Cauldron", "Establishing the new.", "Opprotunity to inspire.", "☲", "☴"),
  IChingInfo(51, "Thunder", "Mobilizing.", "For those about to rock... We salute you!", "☳", "☳"),
  IChingInfo(52, "Mountains", "Immobility.", "The goal is fixed.", "☶", "☶"),
  IChingInfo(53, "Gradual Progress", "Auspicious outlook, infiltration.", "The people help you reach your goal.", "☴", "☶"),
  IChingInfo(54, "A Young Woman Going to Marry", "Marrying.", "Ensure your work is on a solid foundation.", "☳", "☱"),
  IChingInfo(55, "Abundance", "Goal reached. Ambition achieved.", "You have much to gain.", "☳", "☲"),
  IChingInfo(56, "Travel", "Travel.", "New vistas will open up.", "☲", "☶"),
  IChingInfo(57, "Conformity", "Subtle influence.", "This is conformity.", "☴", "☴"),
  IChingInfo(58, "Pleasing", "Overt influence.", "Agreement over the plan.", "☱", "☱"),
  IChingInfo(59, "Dispersal", "Dispersal.", "Emotional development.", "☴", "☵"),
  IChingInfo(60, "Regulation", "Discipline.", "Using fairness, a new order is established.", "☵", "☱"),
  IChingInfo(61, "Truthfulness in the Center", "Staying focused, avoiding misrepresentation.", "What people feel is a valid refelction on what's planned.", "☴", "☱"),
  IChingInfo(62, "Predominance of the Small", "Small surpassing.", "New creations must start small.", "☳", "☶"),
  IChingInfo(63, "Already Accomplished", "Completion.", "The people want the familiar, the familiar is given to them.", "☵", "☲"),
  IChingInfo(64, "Unfinished", "Incomplete.", "Working on a trusted course of action.", "☲", "☵"),
  IChingInfo(65, "Power", "Power.", "Increase in social captital.", "☲", "⚎"),
  IChingInfo(66, "Virtue", "Virtue.", "Doing the right thing when others won't.", "⚎", "☲"),
  IChingInfo(67, "Individuality", "Individuality.", "Doing what you want.", "⚎", "⚎"),
  IChingInfo(68, "Valor", "Valor.", "Doing what's right, even when others do not agree.", "⚎", "☳"),
  IChingInfo(69, "Ambition", "Ambition.", "Follow others to reach your ambition.", "☳", "⚎"),
  IChingInfo(70, "Overpowering", "Overpowering.", "Wanting your own path.", "☲", "⚍"),
  IChingInfo(71, "Good Fortune", "Good Fortune.", "Events bring happiness.", "⚎", "☵"),
  IChingInfo(72, "Assertive", "Assertive.", "In step with the moment.", "⚎", "⚍"),
  IChingInfo(73, "Intuition", "Intuition.", "Operating intuitively for the future.", "⚎", "☴"),
  IChingInfo(74, "Passion", "Passion.", "Caring for what you have.", "☳", "⚍"),
  IChingInfo(75, "Hesitation", "Hesitation.", "Hesitation in carrying out the plan.", "☲", "⚌"),
  IChingInfo(76, "Enchantment", "Enchantment.", "Enchantment with old ways prevents you from seeing new opprotunities.", "⚎", "☰"),
  IChingInfo(77, "Magnetism", "Magnetism.", "People carrying out your plan.", "⚎", "⚌"),
  IChingInfo(78, "Great Conviction", "Conviction.", "Belief in a new plan.", "⚎", "☱"),
  IChingInfo(79, "Glamour", "Glamour.", "The actions of others overwhelm you.", "☳", "⚌"),
  IChingInfo(80, "Prepare", "Preparation.", "Gather goods to prepare for the next step.", "☲", "⚏"),
  IChingInfo(81, "Growth", "Growth.", "Keeping in step brings growth.", "⚎", "☷"),
  IChingInfo(82, "Proficiency", "Proficiency.", "Working with familiar materials, performing familiar actions.", "⚎", "⚏"),
  IChingInfo(83, "Recognition", "Recognition.", "Recognition for one's good works.", "⚎", "☶"),
  IChingInfo(84, "Unfolding", "Unfolding.", "Development of one's material world.", "☳", "⚏"),
  IChingInfo(85, "Misconception", "Misconception.", "The people do not understand what you're doing.", "☵", "⚎"),
  IChingInfo(86, "Tension", "Tension.", "You are a bit behind the times with others.", "⚍", "☲"),
  IChingInfo(87, "Rectify", "Rectify.", "Bringing your actions in line with people's feelings.", "⚍", "⚎"),
  IChingInfo(88, "Transform", "Transform.", "Beginning the work of transforming people's emotions.", "⚍", "☳"),
  IChingInfo(89, "United", "United.", "The sun and the moon are different, yet both follow the same laws.", "☴", "⚎"),
  IChingInfo(90, "Deception", "Deception.", "Things appear to be the same at first glance, but are not.", "☵", "⚍"),
  IChingInfo(91, "Rivalry", "Rivalry.", "A competition that you may not win.", "⚍", "☵"),
  IChingInfo(92, "Dedication", "Dedication.", "Dedication to what holds importance.", "⚍", "⚍"),
  IChingInfo(93, "Good Sport", "Good Sport.", "Victory without gloating.", "⚍", "☴"),
  IChingInfo(94, "Protect", "Protect.", "Protecting a loved one from uncertain influences.", "☴", "⚍"),
  IChingInfo(95, "Scandal", "Scandal.", "Scandalous actions of the past inhibit current plans.", "☵", "⚌"),
  IChingInfo(96, "Uncertain", "Uncertain.", "Uncertain if the current plan can be carried out.", "⚍", "☰"),
  IChingInfo(97, "Restoring", "Restoring.", "Updating your thoughts to match the current emotional environment.", "⚍", "⚌"),
  IChingInfo(98, "Instinct", "Instinct.", "Plans for the immediate future are driven by the emotions of the environmenrt.", "⚍", "☱"),
  IChingInfo(99, "Solemn", "Solemn.", "Your plans, while viable, may seem too serious to others.", "☴", "⚌"),
  IChingInfo(100, "Overindulgent", "Overindulgent.", "The individual engages a bit to much in pleasure for the tastes of the people.", "☵", "⚏"),
  IChingInfo(101, "Dispute", "Dispute.", "There is resistance to your current outlook.", "⚍", "☷"),
  IChingInfo(102, "Tradition", "Tradition.", "Respect for the past.", "⚍", "⚏"),
  IChingInfo(103, "Realism", "Realism.", "Building the future requires a realistic approach.", "⚍", "☶"),
  IChingInfo(104, "Acceptance", "Acceptance.", "Accepting that the world is about to change.", "☴", "⚏"),
  IChingInfo(105, "Interest", "Interest.", "There is interest in your plans.", "☰", "⚎"),
  IChingInfo(106, "Listless", "Listless.", "Disinterest in the plans of the world.", "⚌", "☲"),
  IChingInfo(107, "Performance", "Performance.", "You make a display of your actions, which are acceptable to the people.", "⚌", "⚎"),
  IChingInfo(108, "Elation", "Elation.", "Your excitement leads you on a new course of action.", "⚌", "☳"),
  IChingInfo(109, "Praise", "Praise.", "The people want to see more of your work.", "☱", "⚎"),
  IChingInfo(110, "Intrigue", "Intrigue.", "Secretly wanting your own goals.", "☰", "⚍"),
  IChingInfo(111, "Despondent", "Despondent.", "Others have forgotten the thing you care about.", "⚌", "☵"),
  IChingInfo(112, "Storm", "Emotional storm.", "A powerful burst of emotions.", "⚌", "⚍"),
  IChingInfo(113, "Dissipate", "Dissipate.", "With strong feelings regarding the future, you move beyond the current plan.", "⚌", "☴"),
  IChingInfo(114, "Dauntless", "Dauntless.", "Carrying on with what you believe in despite new fashions.", "☱", "⚍"),
  IChingInfo(115, "Mastering", "Mastering.", "Developing skills.", "☰", "⚌"),
  IChingInfo(116, "Superfluous", "Superfluous.", "Unneeded skills.", "⚌", "☰"),
  IChingInfo(117, "Man", "Mankind.", "Man being Man.", "⚌", "⚌"),
  IChingInfo(118, "Refined", "Refined.", "Improved skills.", "⚌", "☱"),
  IChingInfo(119, "Innovation", "Innovation.", "New skills to be learned.", "☱", "⚌"),
  IChingInfo(120, "Aversion", "Aversion.", "Avoiding those with outdated views.", "☰", "⚏"),
  IChingInfo(121, "Awkwardness", "Awkwardness.", "Outdated modes of conduct. Unskilled interaction.", "⚌", "☷"),
  IChingInfo(122, "Obligation", "Obligation.", "Taking care of responsibilities.", "⚌", "⚏"),
  IChingInfo(123, "Friendship", "Friendship.", "Seeing the value in someone.", "⚌", "☶"),
  IChingInfo(124, "Appreciation", "Appreciation.", "Thankful for good advice.", "☱", "⚏"),
  IChingInfo(125, "Assuage", "Assuage.", "Recovering from past damage.", "☷", "⚎"),
  IChingInfo(126, "Endurance", "Endurance.", "Continuing on.", "⚏", "☲"),
  IChingInfo(127, "Contentment", "Contentment.", "Happy with things as they are.", "⚏", "⚎"),
  IChingInfo(128, "Devotion", "Devotion.", "Content with what you have, you work toward the future.", "⚏", "☳"),
  IChingInfo(129, "Maintaining", "Maintaining.", "Despite new developments by others, you continue doing what you've been doing.", "☶", "⚎"),
  IChingInfo(130, "Penetration", "Penetration.", "Pushing through with no resistance.", "☷", "⚍"),
  IChingInfo(131, "Peace", "Peace.", "No worries or work, just peace.", "⚏", "☵"),
  IChingInfo(132, "Strength", "Strength.", "Being in tune with the world brings strength.", "⚏", "⚍"),
  IChingInfo(133, "Insight", "Insight.", "Insight into what's to come.", "⚏", "☴"),
  IChingInfo(134, "Domination", "Domination.", "Preventing growth using emotional domination.", "☶", "⚍"),
  IChingInfo(135, "Cultivation", "Cultivation.", "Refining the present using the past.", "☷", "⚌"),
  IChingInfo(136, "Stimulation", "Stimulation.", "Updating your beliefs based on current developments.", "⚏", "☰"),
  IChingInfo(137, "Evaluation", "Evaluation.", "Evaluating current accomplishments.", "⚏", "⚌"),
  IChingInfo(138, "Judgement", "Judgement.", "Judging current accomplishments.", "⚏", "☱"),
  IChingInfo(139, "Consummation", "Consummation.", "Beginning a new world.", "☶", "⚌"),
  IChingInfo(140, "Clear Heart", "Clear Heart.", "Honorable work continues.", "☷", "⚏"),
  IChingInfo(141, "Rest", "Rest.", "Resting from labors.", "⚏", "☷"),
  IChingInfo(142, "Determination", "Determination.", "All are doing the work.", "⚏", "⚏"),
  IChingInfo(143, "Work", "Work.", "Building the future.", "⚏", "☶"),
  IChingInfo(144, "Achievement", "Achievement.", "Current work is complete and a foundation is laid for the future.", "☶", "⚏"),
];
final courtCards = {
  "🜂🜂": CourtCard("🜂", "🜂", "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Wands14.jpg/135px-Wands14.jpg", "King of Wands"),
  "🜂🜁": CourtCard("🜂", "🜁", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Wands12.jpg/136px-Wands12.jpg", "Knight of Wands"),
  "🜂🜄": CourtCard("🜂", "🜄", "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Wands13.jpg/137px-Wands13.jpg", "Queen of Wands"),
  "🜂🜃": CourtCard("🜂", "🜃", "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Wands11.jpg/136px-Wands11.jpg", "Page of Wands"),
  "🜄🜄": CourtCard("🜄", "🜄", "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Cups13.jpg/139px-Cups13.jpg", "Queen of Cups"),
  "🜄🜃": CourtCard("🜄", "🜃", "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Cups11.jpg/134px-Cups11.jpg", "Page of Cups"),
  "🜄🜂": CourtCard("🜄", "🜂", "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Cups14.jpg/136px-Cups14.jpg", "King of Cups"),
  "🜄🜁": CourtCard("🜄", "🜁", "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Cups12.jpg/139px-Cups12.jpg", "Knight of Cups"),
  "🜁🜁": CourtCard("🜁", "🜁", "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Swords12.jpg/137px-Swords12.jpg", "Knight of Swords"),
  "🜁🜄": CourtCard("🜁", "🜄", "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Swords13.jpg/134px-Swords13.jpg", "Queen of Swords"),
  "🜁🜃": CourtCard("🜁", "🜃", "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Swords11.jpg/137px-Swords11.jpg", "Page of Swords"),
  "🜁🜂": CourtCard("🜁", "🜂", "https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Swords14.jpg/137px-Swords14.jpg", "King of Swords"),
  "🜃🜃": CourtCard("🜃", "🜃", "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Pents11.jpg/137px-Pents11.jpg", "Page of Pentacles"),
  "🜃🜂": CourtCard("🜃", "🜂", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Pents14.jpg/138px-Pents14.jpg", "King of Pentacles"),
  "🜃🜁": CourtCard("🜃", "🜁", "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Pents12.jpg/136px-Pents12.jpg", "Knight of Pentacles"),
  "🜃🜄": CourtCard("🜃", "🜄", "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Pents13.jpg/136px-Pents13.jpg", "Queen of Pentacles"),
};
final elementTransforms = {
  "|": ElementTransform("|", "Identity", "Unchanged"),
  "-": ElementTransform("-", "Opposite", "Opposite"),
  "→": ElementTransform("→", "Complicating", "Complicating"),
  "←": ElementTransform("←", "Simplifying", "Simplifying"),
  "↑": ElementTransform("↑", "Opposite + Simplifying", "Opposite + Simplifying"),
  "↓": ElementTransform("↓", "Opposite + Complicating", "Opposite + Complicating"),
};
final times = {
  "<": Time("<", "Past"),
  "-": Time("<", "Present"),
  ">": Time("<", "Future"),
};
final elements = {
  "🜂": Element("🜂", "Fire", "Action", {"🜂": ElementTransformTo("🜂", "|"), "🜄": ElementTransformTo("🜄", "-"), "🜁": ElementTransformTo("🜁", "→"), "🜃": ElementTransformTo("🜃", "↓")}),
  "🜄": Element("🜄", "Water", "Emotion", {"🜂": ElementTransformTo("🜂", "-"), "🜄": ElementTransformTo("🜄", "|"), "🜁": ElementTransformTo("🜁", "↓"), "🜃": ElementTransformTo("🜃", "→")}),
  "🜁": Element("🜁", "Air", "Thought", {"🜂": ElementTransformTo("🜂", "←"), "🜄": ElementTransformTo("🜄", "↑"), "🜁": ElementTransformTo("🜁", "|"), "🜃": ElementTransformTo("🜃", "-")}),
  "🜃": Element("🜃", "Earth", "World", {"🜂": ElementTransformTo("🜂", "↑"), "🜄": ElementTransformTo("🜄", "←"), "🜁": ElementTransformTo("🜁", "-"), "🜃": ElementTransformTo("🜃", "|")})
};
