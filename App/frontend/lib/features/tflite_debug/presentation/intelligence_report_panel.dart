import 'dart:convert';

import 'package:flutter/material.dart';

/// Colab-style “Crop Disease Intelligence Report” from Layer 2 JSON.
class IntelligenceReportPanel extends StatelessWidget {
  const IntelligenceReportPanel({super.key, required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final topK = report['top_k_predictions'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _banner(),
        const SizedBox(height: 16),
        _row('🦠', 'Disease', report['disease']?.toString() ?? '—'),
        _row('🌾', 'Crop', report['crop']?.toString() ?? '—'),
        _row('📊', 'Confidence', '${report['confidence']}%'),
        _row('🔬', 'Disease type',
            report['disease_type']?.toString().toUpperCase() ?? '—'),
        _row('🚨', 'Severity', report['severity']?.toString() ?? '—'),
        _row(
          '✅',
          'Is positive',
          (report['is_positive'] == true)
              ? 'YES — disease suspected'
              : 'NO — Plant is healthy',
        ),
        const SizedBox(height: 16),
        _sectionTitle('💊 FIRST-AID REMEDY'),
        Text(
          report['first_aid']?.toString() ?? '—',
          style: const TextStyle(
            color: Colors.white70,
            height: 1.45,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('📋 GRANULAR ACTION PLAN'),
        ...((report['action_plan'] as List<dynamic>? ?? [])
            .map((e) => _bullet(e.toString()))),
        const SizedBox(height: 16),
        _sectionTitle('🌦️ WEATHER-CONTEXTUAL ADVICE'),
        Text(
          report['weather_advice']?.toString() ?? '—',
          style: const TextStyle(color: Colors.white70, height: 1.45),
        ),
        const SizedBox(height: 16),
        _sectionTitle('📉 YIELD & ECONOMIC IMPACT'),
        Text(
          'Expected yield loss: ${report['yield_loss_pct']}%\n'
          'Estimated total loss: ₹${report['economic_loss_rs']}\n'
          'Per-acre loss: ₹${report['economic_loss_per_acre']}',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 16),
        _sectionTitle('🛒 MARKETPLACE ROUTING'),
        _marketplace(report['marketplace'] as Map<String, dynamic>?),
        const SizedBox(height: 16),
        _sectionTitle('🏆 TOP-K PREDICTIONS'),
        ...topK.map((raw) => _topKRow(raw as Map<String, dynamic>)),
        const SizedBox(height: 12),
        Text(
          '🕐 Timestamp: ${report['timestamp']}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 20),
        _sectionTitle('📦 RAW JSON PAYLOAD'),
        const SizedBox(height: 8),
        SelectionArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(report),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                height: 1.35,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900.withValues(alpha: 0.5),
            Colors.teal.shade900.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade700.withValues(alpha: 0.6)),
      ),
      child: const Column(
        children: [
          Text(
            '🌿 CROP DISEASE INTELLIGENCE REPORT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Layer 1 (TFLite) + Layer 2 (protocols + validation)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _row(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('▸ ', style: TextStyle(color: Colors.greenAccent)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketplace(Map<String, dynamic>? m) {
    if (m == null) return const Text('—', style: TextStyle(color: Colors.white54));
    final products = m['recommended_products'];
    final type = m['product_type']?.toString();
    final note = m['note']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type != null)
          Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (products is List)
          ...products.map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Text('🔹 ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text('📌 $note', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _topKRow(Map<String, dynamic> row) {
    final rank = row['rank'];
    final key = row['disease_key']?.toString() ?? '';
    final conf = row['confidence'];
    double bar = 0;
    if (conf is num) bar = (conf / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: bar,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                child: Text(
                  '${conf is num ? conf.toStringAsFixed(1) : '—'}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          if (key.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text(
                key,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }
}
