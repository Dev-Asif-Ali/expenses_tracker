import 'package:hive/hive.dart';
import 'expenses_item.dart';

class ExpensesItemAdapter extends TypeAdapter<ExpensesItem> {
  @override
  final int typeId = 3;

  @override
  ExpensesItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpensesItem(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      dateTime: fields[3] as DateTime,
      category: fields[4] as ExpenseCategory,
      tags: (fields[5] as List).cast<String>(),
      note: fields[6] as String?,
      isRecurring: fields[7] as bool,
      recurringPeriod: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpensesItem obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.amount);
    writer.writeByte(3);
    writer.write(obj.dateTime);
    writer.writeByte(4);
    writer.write(obj.category);
    writer.writeByte(5);
    writer.write(obj.tags);
    writer.writeByte(6);
    writer.write(obj.note);
    writer.writeByte(7);
    writer.write(obj.isRecurring);
    writer.writeByte(8);
    writer.write(obj.recurringPeriod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpensesItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
