import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:terhal_app/form/palette.dart';

class Search extends StatelessWidget {
  final String name;
  final String hintText;
  final Color? color;
  final Widget? prefixIcon;
  final List<String? Function(String?)> validators;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;

  const Search({
    super.key,
    required this.name,
    this.hintText = '',
    this.color,
    this.prefixIcon,
    this.validators = const [],
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      key: key,
      name: name,
      controller: controller,
      onChanged: onChanged,
      decoration: Palette.formFieldDecoration(
        hintText: hintText,
        fillColor: Colors.blueAccent.withOpacity(0.1),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(
                  right: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [prefixIcon!],
                ),
              )
            : null,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
