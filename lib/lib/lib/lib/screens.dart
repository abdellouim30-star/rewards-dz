import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ads.dart';
import 'l10n.dart';
import 'state.dart';

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    const pages = [TasksPage(), QuizPage(), GamePage(), WalletPage(), SettingsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('app')),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Text('⭐ ${s.points}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.task_alt), label: s.t('tasks')),
          NavigationDestination(icon: const Icon(Icons.quiz), label: s.t('quiz')),
          NavigationDestination(icon: const Icon(Icons.sports_esports), label: s.t('games')),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet), label: s.t('wallet')),
          NavigationDestination(icon: const Icon(Icons.settings), label: s.t('settings')),
        ],
      ),
    );
  }
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(s.t('balance')),
            Text('${s.points} ${s.t('points')}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('≈ \$${(s.points / Cfg.pointsPerUsd).toStringAsFixed(2)}'),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Card(
        child: ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(s.t('checkin')),
          subtitle: Text('+${Cfg.checkinPts} ${s.t('points')}'),
          trailing: FilledButton(
            onPressed: s.checkedIn
                ? null
                : () async {
                    await s.claimCheckin();
                  },
            child: Text(s.checkedIn ? s.t('done') : s.t('claim')),
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.play_circle),
          title: Text(s.t('watchAd')),
          subtitle: Text('+${Cfg.adPts} ${s.t('points')} • ${s.t('adsToday')}: ${s.adsToday}/${Cfg.maxAdsPerDay}'),
          trailing: FilledButton(
            onPressed: s.canWatchAd
                ? () {
                    snack(context, s.t('adLoading'));
                    AdService.showRewarded(
                      onReward: () => s.rewardAd(),
                      onFail: () {
                        if (context.mounted) snack(context, s.t('adFail'));
                      },
                    );
                  }
                : null,
            child: Text(s.canWatchAd ? s.t('watch') : s.t('limit')),
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.quiz),
          title: Text(s.t('dailyQuiz')),
          subtitle: Text('+${Cfg.quizPtsPerAnswer} / ${s.t('points')}'),
          trailing: Icon(s.quizDone ? Icons.check_circle : Icons.circle_outlined),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.sports_esports),
          title: Text(s.t('tapGame')),
          subtitle: Text('${s.t('gamesToday')}: ${s.gamesToday}/${Cfg.maxGamesPerDay}'),
          trailing: Icon(s.gamesToday > 0 ? Icons.check_circle : Icons.circle_outlined),
        ),
      ),
    ]);
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool started = false;
  int idx = 0, correct = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.quizDone && !started) {
      return Center(child: Text(s.t('limit'), style: const TextStyle(fontSize: 18)));
    }
    if (!started) {
      return Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: Text(s.t('start')),
          onPressed: () => setState(() => started = true),
        ),
      );
    }
    if (idx >= quizQuestions.length) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${s.t('score')}: $correct/${quizQuestions.length}', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text('+${correct * Cfg.quizPtsPerAnswer} ${s.t('points')}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => setState(() {
              started = false;
              idx = 0;
              correct = 0;
            }),
            child: Text(s.t('ok')),
          ),
        ]),
      );
    }
    final q = quizQuestions[idx];
    final opts = q.opts[s.lang]!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LinearProgressIndicator(value: idx / quizQuestions.length),
        const SizedBox(height: 24),
        Text(q.q[s.lang]!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        for (var o = 0; o < opts.length; o++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () async {
                if (o == q.answer) correct++;
                if (idx == quizQuestions.length - 1) {
                  await s.finishQuiz(correct);
                }
                setState(() => idx++);
              },
              child: Padding(padding: const EdgeInsets.all(10), child: Text(opts[o])),
            ),
          ),
      ]),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool running = false;
  int taps = 0, left = 10;
  String? result;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start() {
    setState(() {
      running = true;
      taps = 0;
      left = 10;
      result = null;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (left <= 1) {
        t.cancel();
        final won = taps >= 20;
        final s = context.read<AppState>();
        await s.finishGame(won);
        if (!mounted) return;
        setState(() {
          running = false;
          left = 0;
          result = won ? s.t('won') : s.t('lost');
        });
      } else {
        setState(() => left--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(s.t('tapGame'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(s.t('tapDesc'), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('${s.t('gamesToday')}: ${s.gamesToday}/${Cfg.maxGamesPerDay}'),
          const SizedBox(height: 24),
          if (running) ...[
            Text('${s.t('time')}: $left   |   ${s.t('taps')}: $taps', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 160,
              child: FilledButton(
                style: FilledButton.styleFrom(shape: const CircleBorder()),
                onPressed: () => setState(() => taps++),
                child: const Icon(Icons.touch_app, size: 64),
              ),
            ),
          ] else ...[
            if (result != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(result!, style: const TextStyle(fontSize: 20))),
            FilledButton(
              onPressed: s.canPlayGame ? start : null,
              child: Text(s.canPlayGame ? s.t('start') : s.t('limit')),
            ),
          ],
        ]),
      ),
    );
  }
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String method = 'BaridiMob';
  final account = TextEditingController();
  final amount = TextEditingController(text: '${Cfg.minWithdraw}');

  @override
  void dispose() {
    account.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(
        child: Text('${s.points} ${s.t('points')}  ≈ \$${(s.points / Cfg.pointsPerUsd).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 4),
      Center(child: Text(s.t('minWithdraw'))),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: method,
        decoration: InputDecoration(labelText: s.t('method'), border: const OutlineInputBorder()),
        items: const ['BaridiMob', 'CCP', 'Flexy', 'Binance Pay']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => method = v!),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: account,
        decoration: InputDecoration(labelText: s.t('account'), border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: amount,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: s.t('amount'), border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () async {
          final ok = await s.requestWithdraw(method, account.text, int.tryParse(amount.text) ?? 0);
          if (context.mounted) snack(context, ok ? s.t('sent') : s.t('notEnough'));
        },
        child: Text(s.t('withdraw')),
      ),
      const Divider(height: 32),
      Text(s.t('history'), style: const TextStyle(fontWeight: FontWeight.bold)),
      for (final w in s.withdrawals)
        ListTile(
          dense: true,
          title: Text('${w['amount']} ${s.t('points')} • ${w['method']}'),
          subtitle: Text('${w['date']}'),
          trailing: Text(s.t(w['status'] as String)),
        ),
    ]);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final code = TextEditingController();

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> openAdmin(AppState s) async {
    final pin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.t('pin')),
        content: TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(c, pin.text == Cfg.adminPin), child: Text(s.t('ok'))),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
    } else if (ok == false) {
      snack(context, s.t('wrongPin'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(s.t('language'), style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'ar', label: Text('العربية')),
          ButtonSegment(value: 'fr', label: Text('Français')),
        ],
        selected: {s.lang},
        onSelectionChanged: (v) => s.setLang(v.first),
      ),
      const Divider(height: 32),
      Text(s.t('referral'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ListTile(
        title: Text(s.t('yourCode')),
        subtitle: Text(s.refCode, style: const TextStyle(fontSize: 20, letterSpacing: 2)),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: s.refCode));
            snack(context, s.t('copied'));
          },
        ),
      ),
      Text('${s.t('invited')}: ${s.refCount}'),
      const SizedBox(height: 8),
      if (!s.usedReferral)
        Row(children: [
          Expanded(
            child: TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: s.t('enterCode'), border: const OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              final ok = await s.applyReferral(code.text);
              if (context.mounted) snack(context, ok ? '+${Cfg.referralBonus}' : s.t('notEnough'));
            },
            child: Text(s.t('apply')),
          ),
        ]),
      const Divider(height: 32),
      OutlinedButton.icon(
        icon: const Icon(Icons.admin_panel_settings),
        label: Text(s.t('admin')),
        onPressed: () => openAdmin(s),
      ),
    ]);
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(s.t('admin'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(title: Text(s.t('users')), trailing: Text('${s.totalEarned}'))),
        const SizedBox(height: 8),
        Text(s.t('history'), style: const TextStyle(fontWeight: FontWeight.bold)),
        for (final w in s.withdrawals)
          Card(
            child: ListTile(
              title: Text('${w['amount']} ${s.t('points')} • ${w['method']}'),
              subtitle: Text('${w['account']}\n${w['date']} • ${s.t(w['status'] as String)}'),
              isThreeLine: true,
              trailing: w['status'] == 'pending'
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: s.t('approve'),
                        onPressed: () => s.setWithdrawStatus(w['id'] as int, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: s.t('reject'),
                        onPressed: () => s.setWithdrawStatus(w['id'] as int, 'rejected'),
                      ),
                    ])
                  : null,
            ),
          ),
      ]),
    );
  }
}
