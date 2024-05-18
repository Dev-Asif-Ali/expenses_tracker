import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  void Function(BuildContext)? deletedTapped;

  ExpenseTile(
      {Key? key,
      required this.name,
      required this.amount,
      required this.dateTime,
      required this.deletedTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          autoClose: true,
          backgroundColor: Colors.grey.withOpacity(.2),
          onPressed: deletedTapped,
          icon: Icons.delete,
          borderRadius: BorderRadius.circular(5),
          spacing: 2,
        ),
      ]),
      child: Card(
        color: Colors.black,
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${dateTime.day}/${dateTime.month}/${dateTime.year}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: Text(
            '\$$amount',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
