import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ConsumptionHistoryScreen extends StatelessWidget {
  const ConsumptionHistoryScreen({super.key});

  Widget buildHistogram(List<double> data, String title, double totalWatts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 150,
          child: BarChart(
            BarChartData(
              backgroundColor: Colors.transparent,
              barGroups: [
                for (int i = 0; i < data.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: data[i],
                      width: 8,
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(2),
                    )
                  ])
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      'D${value.toInt() + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              maxY: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Watts: ${totalWatts.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Historial',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildHistogram(
                [3, 4.5, 5.8, 6.2, 6, 5, 4.3], 'Consumo hoy', 76.90),
            buildHistogram(
                [3, 4.5, 5.8, 6.2, 6, 5, 4.3], 'Consumo este mes', 300.90),
          ],
        ),
      ),

    );
  }
}
