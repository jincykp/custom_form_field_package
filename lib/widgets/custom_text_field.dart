import 'package:flutter/material.dart';
import '../models/field_type.dart';
import '../painters/required_indicator_painter.dart';

/// A customizable text form field widget with built-in validation and required field indicators
class CustomTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController controller;

  /// Label text displayed above the field
  final String labelText;

  /// Hint text displayed inside the field when empty
  final String? hintText;

  /// Whether this field is required
  final bool required;

  /// Color of the required indicator symbol
  final Color requiredSymbolColor;

  /// Size of the required indicator symbol
  final double requiredSymbolSize;

  /// Type of field which determines validation behavior
  final FieldType fieldType;

  /// Custom validator function (used with FieldType.custom)
  final String? Function(String?)? validator;

  /// Callback when the field value changes
  final void Function(String)? onChanged;

  /// Widget to display before the input text
  final Widget? prefixIcon;

  /// Widget to display after the input text
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.required = false,
    this.requiredSymbolColor = Colors.red,
    this.requiredSymbolSize = 10.0,
    required this.fieldType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    if (widget.required) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.required != oldWidget.required) {
      if (widget.required) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    switch (widget.fieldType) {
      case FieldType.username:
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(value)) {
            return 'Enter a valid username (min 3 characters, alphanumeric + underscore only)';
          }
        }
        break;
      case FieldType.email:
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
            return 'Enter a valid email address';
          }
        }
        break;
      case FieldType.password:
        if (value != null && value.isNotEmpty) {
          if (!((value.length >= 6 &&
              RegExp(r'[A-Z]').hasMatch(value) &&
              RegExp(r'[0-9]').hasMatch(value)))) {
            return 'Password must be 6+ characters with 1 uppercase & 1 number';
          }
        }
        break;
      case FieldType.custom:
        return widget.validator?.call(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.labelText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (widget.required)
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: CustomPaint(
                      size: Size(
                        widget.requiredSymbolSize + 4,
                        widget.requiredSymbolSize + 4,
                      ),
                      painter: RequiredIndicatorPainter(
                        color: widget.requiredSymbolColor,
                        size: widget.requiredSymbolSize,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          obscureText: widget.fieldType == FieldType.password
              ? _obscureText
              : false,
          validator: _validate,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.fieldType == FieldType.password
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
