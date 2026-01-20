import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/screens/learn_screen_overall/mnemonics/mnemonics_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MnemonicsPage extends StatefulWidget {
  MnemonicsPage({super.key, this.mnemonicsData, required this.onDelete});
  List<FileInfo>? mnemonicsData;
  final Function onDelete;

  @override
  State<MnemonicsPage> createState() => _MnemonicsPageState();
}

class _MnemonicsPageState extends State<MnemonicsPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: widget.mnemonicsData == null || widget.mnemonicsData!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.psychology_outlined,
                    size: 64,
                    color: Color(0xFF364F6B),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Mnemonics Created",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF364F6B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap + to create mnemonics from your files",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF364F6B),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemBuilder: (_, index) {
                var mnemonics = widget.mnemonicsData![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) =>
                            MnemonicsContent(file: mnemonics, index: index),
                      ),
                    );
                  },
                  child: Dismissible(
                    key: Key(mnemonics.id.toString() + mnemonics.origName),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Mnemonics Set'),
                          content: const Text(
                            'Are you sure you want to delete this mnemonics set?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      widget.onDelete(mnemonics, widget.mnemonicsData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mnemonics set deleted successfully'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF364F6B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Color(0xFF364F6B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mnemonics ${index + 1}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF364F6B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From "${mnemonics.origName}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (mnemonics.mnemonicsFromContent !=
                                      null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${mnemonics.mnemonicsFromContent!.length} memory aids',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF3FC1C9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Mnemonics Set'),
                                    content: const Text(
                                      'Are you sure you want to delete this mnemonics set?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          widget.onDelete(
                                              mnemonics, widget.mnemonicsData);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Mnemonics set deleted successfully'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete mnemonics set',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: widget.mnemonicsData!.length,
            ),
    );
  }
}
