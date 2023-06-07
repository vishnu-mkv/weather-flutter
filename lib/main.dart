import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import './utils.dart';

void main() {
  runApp(MyApp());
}

// stateful app

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

// stateful widget

class _MyAppState extends State<MyApp> {
  // state
  WeatherData? data;
  bool isLoading = true;
  String loactionError = "";
  Position? userPosition;

  // init
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    data = await getWeather("London");
    isLoading = false;
    setState(() {});
  }

  void getLocation() {
    determinePosition().then((position) {
      userPosition = position;
      loactionError = "";
      isLoading = true;
      setState(() {});
      getWeather(null, position.latitude, position.longitude).then((data) {
        isLoading = false;
        this.data = data;
        setState(() {});
      }).catchError((error) {
        print(error);
        loactionError = error.toString();
        setState(() {});
      });
    }).catchError((error) {
      print(error);
      loactionError = error.toString();
      setState(() {});
    });
  }

  // build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Weather"),
          ),
          body: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      Text(
                        "${data!.main!.temp}°C",
                        style: TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        data!.name!,
                        style: const TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      if (loactionError != "")
                        Text(
                          loactionError,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      if (userPosition != null)
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "lat: ${userPosition?.latitude}, lon: ${userPosition?.longitude}",
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              getLocation();
            },
            child: const Icon(Icons.refresh),
          )),
    );
  }
}
