import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield01 extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextfield01({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
                height: 50,
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
                  filled: true,
                  fillColor: const Color.fromARGB(255, 232, 238, 240),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(6),),
                  hintText: hintText,
                          ),
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                        ),
              );
  }
}