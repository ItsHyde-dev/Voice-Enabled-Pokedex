import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  String? url;
  String? name;

  ImageWidget({super.key, this.url, this.name});

  @override
  Widget build(BuildContext context) {
    return (url != null && name != null)
        ? Column(
            children: [Image.network(url!), Text(name!)],
          )
        : Container();
  }
}
