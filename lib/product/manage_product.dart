import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_assignment/database/database_helper.dart';
import 'package:task_assignment/providers/products_provider.dart';
import '../helper/utils.dart';
import '../widgets/text_field.dart';

class ManageProductScreen extends StatefulWidget {
  final bool isEditing;
  final dynamic existingProduct;

  const ManageProductScreen(
      {Key? key, required this.isEditing, this.existingProduct})
      : super(key: key);

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  late TextEditingController nameController, siteNameController;
  late int launchedDateTimeInMillis;
  late ProductProvider productProvider;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double star = 2;
  DateTime? initialDateTime;

  @override
  void initState() {
    super.initState();
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    nameController = TextEditingController();
    siteNameController = TextEditingController();
    if (widget.isEditing) {
      if (widget.existingProduct != null) {
        nameController.text = widget.existingProduct[DatabaseHelper.columnName];
        siteNameController.text =
            widget.existingProduct[DatabaseHelper.columnSiteName];
        star = double.parse(
            widget.existingProduct[DatabaseHelper.columnStar].toString());
        initialDateTime = DateTime.fromMillisecondsSinceEpoch(
            widget.existingProduct[DatabaseHelper.columnDateTime]);

        launchedDateTimeInMillis = initialDateTime?.millisecondsSinceEpoch ?? 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "${widget.isEditing ? "Edit" : "Add"} Product",
          style: const TextStyle(
            color: Utils.secondary,
          ),
        ),
        backgroundColor: Utils.brandColor,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(
              Utils.textSize,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlutterTextField(
                  enabled: !widget.isEditing,
                  labelName: "Name",
                  initialValue: nameController.text,
                  onChanged: (value) => nameController.text = value,
                  validator: (value) {
                    if ((value ?? "").isEmpty) {
                      return "Name field is required";
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                FlutterTextField(
                  labelName: "Site Name",
                  initialValue: siteNameController.text,
                  onChanged: (value) => siteNameController.text = value,
                  validator: (value) {
                    if ((value ?? "").isEmpty) {
                      return "Site Name field is required";
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                // DateTimeField(
                //   format: DateFormat("dd-MM-yyyy"),
                //   initialValue: initialDateTime,
                //   onShowPicker: (context, currentValue) {
                //     return showDatePicker(
                //         context: context,
                //         firstDate: DateTime(1900),
                //         initialDate: currentValue ?? DateTime.now(),
                //         lastDate: DateTime(2100));
                //   },
                //   onChanged: (date) {
                //     launchedDateTimeInMillis =
                //             date?.microsecondsSinceEpoch ?? 0;
                //         print("DateTime: ${launchedDateTimeInMillis}");
                //   },
                //   decoration: const InputDecoration(
                //     label: Text(
                //       "Launched Date",
                //       style: TextStyle(
                //         /*color: Utils.brandColor,*/
                //         fontSize: Utils.textSize,
                //       ),
                //     ),
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide(
                //         color: Utils.secondary,
                //         width: 4,
                //       ),
                //     ),
                //   ),
                // ),

                DateTimeField(
                  validator: (dateTime) {
                    if (dateTime == null) {
                      return "Launched Date field is required";
                    } else {
                      return null;
                    }
                  },
                  initialValue: initialDateTime,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  format: DateFormat("dd-MM-yyyy HH:mm"),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1500),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                  onChanged: (dateTime) {
                    launchedDateTimeInMillis =
                        dateTime?.millisecondsSinceEpoch ?? 0;
                    print("DateTime: ${launchedDateTimeInMillis}");
                  },
                  decoration: const InputDecoration(
                    label: Text(
                      "Launched Date",
                      style: TextStyle(
                        /*color: Utils.brandColor,*/
                        fontSize: Utils.textSize,
                      ),
                    ),
                    border: OutlineInputBorder(
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

                RatingBar.builder(
                  initialRating: star,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    star = rating;
                    print(star.round());
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: RaisedButton(
          onPressed: () async {
            var isValid = _formKey.currentState?.validate() ?? false;
            if (isValid) {
              List productExisting = await DatabaseHelper.instance.queryRow(nameController.text);
              if (productExisting.isNotEmpty && !widget.isEditing) {
                print("Product is exist!");

                _scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Product is exist! Please enter new product.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (widget.isEditing) {
                await DatabaseHelper.instance.update(
                  {
                    DatabaseHelper.columnId: widget.existingProduct[DatabaseHelper.columnId],
                    /*DatabaseHelper.columnName: nameController.text,*/
                    DatabaseHelper.columnSiteName: siteNameController.text,
                    DatabaseHelper.columnStar: star.round(),
                    DatabaseHelper.columnDateTime: launchedDateTimeInMillis,
                  },
                ).then((value) {
                  print("Update Id: $value");
                  productProvider.isReload = true;
                  Navigator.pop(context, true);
                });
              } else {
                await DatabaseHelper.instance.insert(
                  {
                    DatabaseHelper.columnName: nameController.text,
                    DatabaseHelper.columnSiteName: siteNameController.text,
                    DatabaseHelper.columnStar: star.round(),
                    DatabaseHelper.columnDateTime: launchedDateTimeInMillis,
                  },
                ).then((value) {
                  print("Insert Id: $value");
                  productProvider.isReload = true;
                  Navigator.pop(context, true);
                });
              }
            }
          },
          color: Utils.brandColor,
          child: Text(
            widget.isEditing ? "UPDATE" : "SUBMIT",
            style: const TextStyle(
              color: Utils.secondary,
              fontSize: Utils.textSize,
            ),
          ),
        ),
      ),
    );
  }
}
