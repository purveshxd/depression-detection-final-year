import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dep_app/api_service.dart';
import 'package:dep_app/widget/filled_button_custom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ip_provider = StateProvider<String>((ref) {
  return '';
});

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  File? edfFile;
  String errMsg = '';
  Uint8List? message;
  String? result;
  bool isRecieved = false;
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    TextEditingController ip = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Enter IP address"),
                    content: TextField(
                      controller: ip,
                      
                      decoration: const InputDecoration(hintText: 'IP'),
                    ),
                    actions: [
                      FilledButton.tonal(
                          onPressed: () {
                            ref.watch(ip_provider.notifier).update(
                                  (state) => ip.text,
                                );
                            Navigator.pop(context);
                          },
                          child: const Text('Done'))
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.code_rounded))
        ],
        elevation: 10,
        centerTitle: true,
        title: const Text("Depression Detection"),
      ),
      body: SafeArea(
        child: Center(
            child: isUploading
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      isRecieved ? const SizedBox() : const Spacer(),
                      Container(
                        margin: const EdgeInsets.all(25),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              isRecieved
                                  ? BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      spreadRadius: 3,
                                      blurRadius: 15,
                                      blurStyle: BlurStyle.normal)
                                  : const BoxShadow(color: Colors.transparent),
                            ]),
                        child: isRecieved
                            ? Image.memory(
                                message!,
                              )
                            : errMsg.isEmpty
                                ? Text(
                                    "Select and upload an EDF file to display graphs and results",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                22),
                                  )
                                : Text(errMsg),
                      ),
                      Visibility(
                        visible: result != null,
                        child: Chip(
                          label: Text(result.toString()),
                          shape: const StadiumBorder(),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      edfFile != null
                          ? Chip(
                              label: Text(
                                  "File Name: ${edfFile!.path.split('/').last}"),
                              shape: const StadiumBorder(),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            )
                          : Container(),
                      const Spacer(),
                    ],
                  )),
      ),
      bottomSheet: BottomSheet(
        shape: const RoundedRectangleBorder(),
        // elevation: 0,
        onClosing: () {},
        builder: (context) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilledButtonCustom(
                label: "Select File",
                icon: const Icon(Icons.folder_rounded),
                onPressed: () async {
                  FilePickerResult? file = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: ['bin']);

                  if (file != null) {
                    setState(() {
                      edfFile = File(file.paths[0]!);
                    });
                  }
                  log(file!.paths.elementAt(0).toString());
                },
              ),
              FilledButtonCustom(
                label: "Upload",
                icon: const Icon(Icons.file_upload_rounded),
                onPressed: () async {
                  setState(() {
                    isUploading = true;
                  });
                  try {
                    final resp = await ApiService.uploadFile(
                        edfFile!, ref.watch(ip_provider));
                    if (resp.imageData.isNotEmpty) {
                      setState(() {
                        message = resp.imageData;

                        if (resp.result == 'H') {
                          result = "The patient is Healthy";
                        } else {
                          result = "The patient is Depressed";
                        }
                        isRecieved = true;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      errMsg = e.toString();
                    });
                  }
                  setState(() {
                    isUploading = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
