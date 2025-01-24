import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class FlutterDropdownSearch extends StatefulWidget {
  final TextEditingController? textController;
  final String? hintText;
  final List<String>? items;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? dropdownTextStyle;
  final IconData? suffixIcon;
  final double? dropdownHeight;
  final Color? dropdownBgColor;
  final InputBorder? textFieldBorder;
  final EdgeInsetsGeometry? contentPadding;
  final String labelText;
  final bool isRequired;

  const FlutterDropdownSearch({
    super.key,
    required this.textController,
    this.hintText,
    required this.items,
    this.hintStyle,
    this.style,
    this.dropdownTextStyle,
    this.suffixIcon,
    this.dropdownHeight,
    this.dropdownBgColor,
    this.textFieldBorder,
    this.contentPadding,
    required this.labelText,
    required this.isRequired
  });

  @override
  State<FlutterDropdownSearch> createState() => _FlutterDropdownSearchState();
}

class _FlutterDropdownSearchState extends State<FlutterDropdownSearch> {
  bool _isTapped = false; // Used to show or hide the dropdown
  List<String> _filteredList = [];
  List<String> _subFilteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.items!;
    _subFilteredList = _filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.labelText, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 5), // Space between text and image
           widget.isRequired == true?Text("*", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)): SizedBox.shrink(),

          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Use a neutral color or AppColors.greyHundred
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: widget.textController,
              onChanged: (val) {
                setState(() {
                  _filteredList = _subFilteredList
                      .where((element) => element
                      .toLowerCase()
                      .contains(widget.textController!.text.toLowerCase()))
                      .toList();
                });
              },
              validator: (val) => val!.isEmpty ? 'Field can\'t be empty' : null,
              style: widget.style ?? TextStyle(color: Colors.grey.shade800, fontSize: 16.0),
              onTap: () {
                setState(() {
                  _isTapped = true; // Show dropdown when tapped
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.greyHundred,
                border: InputBorder.none,
                hintText: widget.hintText,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _isTapped = !_isTapped; // Toggle dropdown visibility
                    });
                  },
                  child: Icon(
                    _isTapped ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 25,
                  ),
                ),
                suffixIconConstraints: BoxConstraints.loose(MediaQuery.of(context).size),
                // Show the clear icon only when the text field is not empty
                suffix: widget.textController!.text.isNotEmpty
                    ? InkWell(
                  onTap: () {
                    widget.textController!.clear();
                    setState(() {
                      _filteredList = widget.items!;
                    });
                  },
                  child: const Icon(Icons.clear, color: Colors.grey),
                )
                    : null,
              ),
            ),
          ),
        ),
        // Dropdown Items
        _isTapped && _filteredList.isNotEmpty
            ? Container(
          height: widget.dropdownHeight ?? 150.0,
          color: widget.dropdownBgColor ?? Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _isTapped = false; // Close dropdown when item is selected
                    widget.textController!.text = _filteredList[index]; // Set the selected item
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _filteredList[index],
                    style: widget.dropdownTextStyle ??
                        TextStyle(color: Colors.grey.shade800, fontSize: 16.0),
                  ),
                ),
              );
            },
          ),
        )
            : SizedBox.shrink(),
      ],
    );
  }
}
