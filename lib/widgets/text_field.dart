import 'package:flutter/material.dart';
import '../helper/utils.dart';

class FlutterTextField extends StatelessWidget {
  final String labelName;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? controller;
  final bool? enabled;

  const FlutterTextField(
      {Key? key,
      required this.labelName,
      this.onChanged,
      this.initialValue,
      this.validator,
      this.autovalidateMode, this.controller, this.enabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          enabled: enabled,
          validator: validator,
          autovalidateMode: autovalidateMode,
          controller: controller,
          onChanged: onChanged,
          initialValue: initialValue,
          decoration: InputDecoration(
            label: Text(
              labelName,
              style: const TextStyle(
                /*color: Utils.brandColor,*/
                fontSize: Utils.textSize,
              ),
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Utils.secondary,
                width: 4,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
