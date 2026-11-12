const Map<String, Map<String, String>> _t = {
  'app': {'ar': 'مكافآت DZ', 'fr': 'Récompenses DZ'},
  'tasks': {'ar': 'المهام', 'fr': 'Tâches'},
  'quiz': {'ar': 'مسابقة', 'fr': 'Quiz'},
  'games': {'ar': 'ألعاب', 'fr': 'Jeux'},
  'wallet': {'ar': 'المحفظة', 'fr': 'Portefeuille'},
  'settings': {'ar': 'الإعدادات', 'fr': 'Paramètres'},
  'balance': {'ar': 'رصيدك', 'fr': 'Votre solde'},
  'points': {'ar': 'نقطة', 'fr': 'pts'},
  'checkin': {'ar': 'الحضور اليومي', 'fr': 'Présence quotidienne'},
  'claim': {'ar': 'استلم', 'fr': 'Récupérer'},
  'done': {'ar': 'تم ✓', 'fr': 'Fait ✓'},
  'watchAd': {'ar': 'شاهد إعلانًا واربح', 'fr': 'Regarde une pub et gagne'},
  'watch': {'ar': 'شاهد', 'fr': 'Regarder'},
  'adLoading': {'ar': 'جارٍ تحميل الإعلان...', 'fr': 'Chargement de la pub...'},
  'adFail': {'ar': 'لا يوجد إعلان الآن، حاول لاحقًا', 'fr': 'Aucune pub disponible, réessayez'},
  'limit': {'ar': 'وصلت للحد اليومي', 'fr': 'Limite quotidienne atteinte'},
  'dailyQuiz': {'ar': 'مسابقة اليوم', 'fr': 'Quiz du jour'},
  'start': {'ar': 'ابدأ', 'fr': 'Commencer'},
  'score': {'ar': 'نتيجتك', 'fr': 'Votre score'},
  'tapGame': {'ar': 'تحدي السرعة', 'fr': 'Défi de vitesse'},
  'tapDesc': {
    'ar': 'اضغط 20 مرة خلال 10 ثوانٍ لتربح 15 نقطة',
    'fr': 'Appuyez 20 fois en 10 s pour gagner 15 pts'
  },
  'taps': {'ar': 'الضغطات', 'fr': 'Appuis'},
  'time': {'ar': 'الوقت', 'fr': 'Temps'},
  'won': {'ar': 'مبروك! ربحت 15 نقطة', 'fr': 'Bravo ! +15 pts'},
  'lost': {'ar': 'حاول مرة أخرى', 'fr': 'Réessayez'},
  'withdraw': {'ar': 'طلب سحب', 'fr': 'Demande de retrait'},
  'method': {'ar': 'طريقة الدفع', 'fr': 'Mode de paiement'},
  'account': {'ar': 'رقم الحساب / الهاتف', 'fr': 'N° de compte / téléphone'},
  'amount': {'ar': 'عدد النقاط', 'fr': 'Nombre de points'},
  'minWithdraw': {'ar': 'الحد الأدنى للسحب: 5000 نقطة', 'fr': 'Retrait minimum : 5000 pts'},
  'notEnough': {'ar': 'رصيد غير كافٍ أو بيانات ناقصة', 'fr': 'Solde insuffisant ou données manquantes'},
  'sent': {'ar': 'تم إرسال الطلب', 'fr': 'Demande envoyée'},
  'history': {'ar': 'سجل السحب', 'fr': 'Historique des retraits'},
  'pending': {'ar': 'قيد المراجعة', 'fr': 'En attente'},
  'approved': {'ar': 'تم الدفع', 'fr': 'Payé'},
  'rejected': {'ar': 'مرفوض', 'fr': 'Refusé'},
  'referral': {'ar': 'نظام الإحالة', 'fr': 'Parrainage'},
  'yourCode': {'ar': 'كود الإحالة الخاص بك', 'fr': 'Votre code de parrainage'},
  'copied': {'ar': 'تم النسخ', 'fr': 'Copié'},
  'enterCode': {'ar': 'أدخل كود صديق (+50 نقطة)', 'fr': 'Code d\'un ami (+50 pts)'},
  'apply': {'ar': 'تطبيق', 'fr': 'Appliquer'},
  'invited': {'ar': 'الأصدقاء المدعوون', 'fr': 'Amis invités'},
  'language': {'ar': 'اللغة', 'fr': 'Langue'},
  'admin': {'ar': 'لوحة المشرف', 'fr': 'Espace admin'},
  'pin': {'ar': 'رمز المشرف', 'fr': 'Code admin'},
  'wrongPin': {'ar': 'رمز خاطئ', 'fr': 'Code incorrect'},
  'approve': {'ar': 'قبول', 'fr': 'Valider'},
  'reject': {'ar': 'رفض', 'fr': 'Refuser'},
  'users': {'ar': 'إجمالي النقاط الممنوحة', 'fr': 'Total de points accordés'},
  'ok': {'ar': 'موافق', 'fr': 'OK'},
  'cancel': {'ar': 'إلغاء', 'fr': 'Annuler'},
  'adsToday': {'ar': 'إعلانات اليوم', 'fr': 'Pubs du jour'},
  'gamesToday': {'ar': 'ألعاب اليوم', 'fr': 'Jeux du jour'},
};

String tr(String lang, String key) => _t[key]?[lang] ?? key;

class QuizQ {
  final Map<String, String> q;
  final Map<String, List<String>> opts;
  final int answer;
  const QuizQ(this.q, this.opts, this.answer);
}

const List<QuizQ> quizQuestions = [
  QuizQ(
    {'ar': 'ما عاصمة الجزائر؟', 'fr': 'Quelle est la capitale de l\'Algérie ?'},
    {
      'ar': ['وهران', 'الجزائر', 'قسنطينة'],
      'fr': ['Oran', 'Alger', 'Constantine']
    },
    1,
  ),
  QuizQ(
    {'ar': 'في أي سنة استقلت الجزائر؟', 'fr': 'En quelle année l\'Algérie est-elle devenue indépendante ?'},
    {
      'ar': ['1954', '1962', '1975'],
      'fr': ['1954', '1962', '1975']
    },
    1,
  ),
  QuizQ(
    {'ar': 'كم عدد ولايات الجزائر؟', 'fr': 'Combien de wilayas compte l\'Algérie ?'},
    {
      'ar': ['48', '58', '69'],
      'fr': ['48', '58', '69']
    },
    1,
  ),
  QuizQ(
    {'ar': 'ما أكبر صحراء في العالم الحارّة؟', 'fr': 'Quel est le plus grand désert chaud du monde ?'},
    {
      'ar': ['الصحراء الكبرى', 'غوبي', 'كالاهاري'],
      'fr': ['Sahara', 'Gobi', 'Kalahari']
    },
    0,
  ),
  QuizQ(
    {'ar': 'كم يساوي 12 × 12؟', 'fr': 'Combien font 12 × 12 ?'},
    {
      'ar': ['124', '144', '154'],
      'fr': ['124', '144', '154']
    },
    1,
  ),
];
