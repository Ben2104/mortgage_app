import 'package:flutter/material.dart';

import 'modify_screen.dart';
import 'mortgage.dart';

/// Left screen: read-only summary + Terms and Conditions + Modify Data.
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Mortgage _mortgage = Mortgage();
  bool _termsAccepted = false;

  Future<void> _modify() async {
    // Share data between screens: pass the model in, get the edited model back.
    final result = await Navigator.of(context).push<Mortgage>(
      MaterialPageRoute(builder: (_) => ModifyScreen(mortgage: _mortgage)),
    );
    if (result != null) setState(() => _mortgage = result);
  }

  Future<void> _onTermsChanged(bool? checked) async {
    if (checked != true) {
      setState(() => _termsAccepted = false);
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const Text(
          'Do you confirm that you have read and agree to the terms and '
          'conditions of this mortgage?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _termsAccepted = accepted ?? false);
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 16))),
            Expanded(flex: 2, child: Text(value, style: const TextStyle(fontSize: 16))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row('Amount', _mortgage.getFormattedAmount()),
          _row('Years', '${_mortgage.getYears()}'),
          _row('Interest Rate', _mortgage.getFormattedRate()),
          const Divider(color: Colors.red, thickness: 2),
          _row('Monthly Payment', _mortgage.formattedMonthlyPayment()),
          _row('Total Payment', _mortgage.formattedTotalPayment()),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Terms and Conditions'),
            value: _termsAccepted,
            onChanged: _onTermsChanged,
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _modify,
              child: const Text('MODIFY DATA'),
            ),
          ),
        ],
      ),
    );
  }
}
