import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:terhal_app/form/palette.dart';

class ControlText extends StatelessWidget {
  final String name;
  final String label;
  final void Function(String?)? onChanged;

  const ControlText({
    super.key,
    required this.name,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic)> validators = [];

    return FormBuilderTextField(
      key: key,
      onChanged: onChanged,
      name: name,
      decoration: Palette.formFieldDecoration(label: label),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
