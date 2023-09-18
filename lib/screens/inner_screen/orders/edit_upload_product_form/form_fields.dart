import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../consts/validator.dart';
import '../../../../widgets/subtitle_text.dart';

class FormFields extends StatelessWidget {
  const FormFields({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController priceController,
    required TextEditingController quantityController,
    required TextEditingController descriptionController,
  })  : _formKey = formKey,
        _titleController = titleController,
        _priceController = priceController,
        _quantityController = quantityController,
        _descriptionController = descriptionController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _titleController;
  final TextEditingController _priceController;
  final TextEditingController _quantityController;
  final TextEditingController _descriptionController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            key: const ValueKey('Title'),
            maxLength: 80,
            minLines: 1,
            maxLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Product Title',
              label: Text("Title"),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            validator: (value) {
              return MyValidators.uploadProdTexts(
                value: value,
                toBeReturnedString: "Please enter a valid title",
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: TextFormField(
                  controller: _priceController,
                  key: const ValueKey('Price \$'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                      hintText: 'Product Price',
                      label: Text("Price"),
                      hintStyle: TextStyle(color: Colors.grey),
                      prefix: SubtitleTextWidget(
                        label: "\$ ",
                        fontSize: 16,
                        color: Colors.green,
                      )),
                  validator: (value) {
                    return MyValidators.uploadProdTexts(
                      value: value,
                      toBeReturnedString: "Price is missing",
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                flex: 1,
                child: TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  key: const ValueKey('Quantity'),
                  decoration: const InputDecoration(
                    hintText: 'Product Qty',
                    label: Text("Quantity"),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (value) {
                    return MyValidators.uploadProdTexts(
                      value: value,
                      toBeReturnedString: "Quantity is missed",
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            key: const ValueKey('Description'),
            controller: _descriptionController,
            minLines: 5,
            maxLines: 8,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Product description',
            ),
            validator: (value) {
              return MyValidators.uploadProdTexts(
                value: value,
                toBeReturnedString: "Description is missed",
              );
            },
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
