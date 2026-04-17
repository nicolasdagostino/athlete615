import 'package:flutter/material.dart';

class PersonalRecordTile extends StatelessWidget {
  const PersonalRecordTile({
    super.key,
    required this.exercise,
    required this.value,
  });

  final String exercise;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(exercise),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
