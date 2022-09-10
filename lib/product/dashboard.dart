import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:task_assignment/database/database_helper.dart';
import 'package:task_assignment/product/manage_product.dart';
import '../helper/utils.dart';
import '../widgets/custom_dialog.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Future<List<Map<String, dynamic>>> productListFuture;
  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    productList = [];
    productListFuture = DatabaseHelper.instance.queryAllRows();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(
            color: Utils.secondary,
          ),
        ),
        backgroundColor: Utils.brandColor,
        actions: [
          IconButton(
            color: Utils.secondary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ManageProductScreen(isEditing: false);
                  },
                ),
              ).then((value){
                if(value??false){
                  setState((){
                    productListFuture = DatabaseHelper.instance.queryAllRows();
                  });
                }
              });
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: _getBody(),
      ),
    );
  }

  _getBody() {
    return FutureBuilder(
      future: productListFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // TODO: Handle this case.
            return const Center(
              child: Text(
                "No product(s) found",
                style: TextStyle(
                  color: Utils.brandColor,
                  fontSize: Utils.textSize,
                ),
              ),
            );
            break;
          case ConnectionState.waiting:
            // TODO: Handle this case.
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
            // TODO: Handle this case.
            break;
          case ConnectionState.done:
            // TODO: Handle this case.
            if (snapshot.hasData) {
              productList = snapshot.data ?? [];
              print("Product List $productList");
              return productList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        dynamic product = productList[index];
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                8,
                              ),
                              child: Card(
                                color: Utils.secondary,
                                elevation: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    8,
                                  ),
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _renderRow(
                                        "Name:",
                                        productList[index]
                                            [DatabaseHelper.columnName],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      _renderRow(
                                        "Site Name:",
                                        productList[index]
                                            [DatabaseHelper.columnSiteName],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      _renderRow(
                                        "Launched Date:",
                                        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(productList[index][DatabaseHelper.columnDateTime])),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      // _renderRow(
                                      //   "Popularity:",
                                      //   "${productList[index][DatabaseHelper.columnStar]} Star",
                                      // ),
                                      // const SizedBox(
                                      //   height: 8,
                                      // ),

                                      Container(
                                        height: 40,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: productList[index][DatabaseHelper.columnStar],
                                          itemBuilder: (context,index){
                                            return const Icon(Icons.star);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 0,
                              child: CircleAvatar(
                                radius: Utils.textSize,
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogBox(
                                          title: "",
                                          descriptions:
                                              "Do you really want to delete?",
                                          text: "Yes",
                                          onChanged: (value) async {
                                            if (value ?? false) {
                                              await DatabaseHelper.instance
                                                  .delete(
                                                    productList[index][
                                                        DatabaseHelper
                                                            .columnId],
                                                  )
                                                  .then(
                                                    (value) => print(
                                                        "Deleted Id $value"),
                                                  );
                                              setState((){
                                                productListFuture = DatabaseHelper.instance.queryAllRows();
                                              });
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: Utils.textSize,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 54,
                              top: 0,
                              child: CircleAvatar(
                                radius: Utils.textSize,
                                backgroundColor: Utils.brandColor,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ManageProductScreen(
                                            isEditing: true,
                                            existingProduct: product,
                                          );
                                        },
                                      ),
                                    ).then((value){
                                      if(value??false){
                                        setState((){
                                          productListFuture = DatabaseHelper.instance.queryAllRows();
                                        });
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: Utils.textSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No product(s) found",
                        style: TextStyle(
                          color: Utils.brandColor,
                          fontSize: Utils.textSize,
                        ),
                      ),
                    );
            }
            break;
        }
        return const Center(
          child: Text(
            "No product(s) found",
            style: TextStyle(
              color: Utils.brandColor,
              fontSize: Utils.textSize,
            ),
          ),
        );
      },
    );
  }

  _renderRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Text(
            title,
          ),
        ),
        Expanded(
          child: Text(
            value,
          ),
        )
      ],
    );
  }
}
