import 'dart:math';

import 'package:expenses_tracker/core/datetime/date_time.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_state.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/widgets/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/expenses_repo_impl.dart';

class ExpenseSummary extends StatelessWidget {
  final ExpenseRepositoryImpl repository;

  final DateTime startOfWeek;
  const ExpenseSummary(
      {super.key, required this.startOfWeek, required this.repository});

  double calculateMax(
    String sunday,
    String monday,
    String tueday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
  ) {
    double max = 100;

    List<double> values = [
      repository.calculateDailyExpenses()[sunday] ?? 0,
      repository.calculateDailyExpenses()[monday] ?? 0,
      repository.calculateDailyExpenses()[tueday] ?? 0,
      repository.calculateDailyExpenses()[wednesday] ?? 0,
      repository.calculateDailyExpenses()[thursday] ?? 0,
      repository.calculateDailyExpenses()[friday] ?? 0,
      repository.calculateDailyExpenses()[saturday] ?? 0,
    ];
    values.sort();

    max = values.last * 1.1;
    log(max);
    return max == 0 ? 100 : max;
  }
//calculate the week total

  String calculateWeekTotal(
    String sunday,
    String monday,
    String tueday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
  ) {
    List<double> values = [
      repository.calculateDailyExpenses()[sunday] ?? 0,
      repository.calculateDailyExpenses()[monday] ?? 0,
      repository.calculateDailyExpenses()[tueday] ?? 0,
      repository.calculateDailyExpenses()[wednesday] ?? 0,
      repository.calculateDailyExpenses()[thursday] ?? 0,
      repository.calculateDailyExpenses()[friday] ?? 0,
      repository.calculateDailyExpenses()[saturday] ?? 0,
    ];
    double total = 0;
    for (int i = 0; i < values.length; i++) {
      total += values[i];
    }
    return total.toString();
  }

  @override
  Widget build(BuildContext context) {
    String sunday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 0)));
    String monday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 1)));
    String tuesday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 2)));
    String wednesday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 3)));
    String thursday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 4)));
    String friday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 5)));
    String saturday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 6)));
    return BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ExpensesAdded || state is ExpensesLoaded) {
            return Column(
              children: [
                  Container(
                    height: MediaQuery.of(context).size.height*.15,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Total Expenses of Week',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                  '\$${calculateWeekTotal(sunday, monday, tuesday, wednesday, thursday, friday, saturday)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 40,
                ),
                BarGraph(
                  // maxYy: calculateMax( sunday, monday, tuesday, wednesday, thursday, friday, saturday),
                  maxYy: 100,

                  sunAmount: repository.calculateDailyExpenses()[sunday] ?? 0,
                  monAmount: repository.calculateDailyExpenses()[monday] ?? 0,
                  tueAmount: repository.calculateDailyExpenses()[tuesday] ?? 0,
                  wedAmount:
                      repository.calculateDailyExpenses()[wednesday] ?? 0,
                  thuAmount: repository.calculateDailyExpenses()[thursday] ?? 0,
                  friAmount: repository.calculateDailyExpenses()[friday] ?? 0,
                  satAmount: repository.calculateDailyExpenses()[saturday] ?? 0,
                ),
              ],
            );
          }
          return const Scaffold();
        });
  }
}
