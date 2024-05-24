import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:penniverse/dao/category_dao.dart';
import 'package:penniverse/events.dart';
import 'package:penniverse/model/category.model.dart';
import 'package:penniverse/widgets/dialog/category_form.dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryDao _categoryDao = CategoryDao();
  EventListener? _categoryEventListener;
  List<Category> _categories = [];

  void loadData() async {
    List<Category> categories = await _categoryDao.find();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      loadData();
    });
  }

  @override
  void dispose() {
    _categoryEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        itemCount: _categories.length,
        itemBuilder: (builder, index) {
          Category category = _categories[index];
          double expenseProgress = (category.expense ?? 0) / (category.budget ?? 0);

          return Slidable(
            key: Key(category.id.toString()),
            direction: Axis.horizontal,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    await _categoryDao.delete(category.id!);
                    setState(() {
                      _categories.removeAt(index);
                    });
                    globalEvent.emit("category_update");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${category.name} deleted')),
                    );
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (builder) => CategoryForm(category: category),
                );
              },
              leading: CircleAvatar(
                backgroundColor: category.color.withOpacity(0.2),
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: expenseProgress.isFinite
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: expenseProgress,
                  semanticsLabel: expenseProgress.toString(),
                ),
              )
                  : Text(
                "No budget",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Colors.grey,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            color: Colors.grey.withAlpha(25),
            height: 1,
            margin: const EdgeInsets.only(left: 75, right: 20),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        heroTag: "category-hero-fab",
        onPressed: () {
          showDialog(
            context: context,
            builder: (builder) => const CategoryForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
