import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistogramChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final double watts;
  final VoidCallback onSearch;

  const HistogramChart({
    super.key,
    required this.data,
    required this.title,
    required this.watts,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                onPressed: onSearch,
                icon: const Icon(Icons.search, color: Colors.purple),
              )
            ],
          ),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  data.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index],
                        width: 14,
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt() + 1}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watts: ${watts.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
