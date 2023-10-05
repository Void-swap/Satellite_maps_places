import 'dart:async';
//import 'package:fab_circular_menu/fab_circular_menu.dart';

import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/provider/search_places.dart';
import 'package:maps/services/map_services.dart';

import 'models/auto_complete_result.dart';

class MapsScreen extends ConsumerStatefulWidget {
  const MapsScreen({super.key});

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends ConsumerState<MapsScreen> {
  Completer<GoogleMapController> _controller = Completer();
//debounce the async call during search
  Timer? _debounce;
//Toggling UI
  bool searchToggle = false;
  bool radiusSlider = false;
  bool cardTapped = false;
  bool pressedNear = false;
  bool getDirections = false;
//marker set
  Set<Marker> _marker = Set<Marker>();
  int markerIdCounter = 1;
//Text Editing Controllers
  TextEditingController searchController = TextEditingController();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void _setMarker(point) {
    var counter = markerIdCounter++;
    final Marker marker = Marker(
        markerId: MarkerId("marker_$counter"),
        position: point,
        onTap: () {},
        icon: BitmapDescriptor.defaultMarker);

    setState(() {
      _marker.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final allSearchResults = ref.watch(placeResultsProvider);
    final searchFlag = ref.watch(searchToggleProvider);

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: screenHeight,
                    width: screenWidth,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      markers: _marker,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  searchToggle
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(15, 40, 15, 5),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white),
                                child: TextFormField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    border: InputBorder.none,
                                    hintText: "search",
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        searchToggle = false;
                                        searchController.text = " ";
                                        _marker = {};
                                        searchFlag.toggleSearch();
                                      },
                                      icon: Icon(Icons.close),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (_debounce?.isActive ?? false)
                                      _debounce?.cancel();
                                    _debounce = Timer(
                                        Duration(milliseconds: 700), () async {
                                      if (value.length > 2) {
                                        if (!searchFlag.searchToggle) {
                                          searchFlag.toggleSearch();
                                          _marker = {};
                                        }
                                        List<AutoCompleteResult> searchResults =
                                            await MapServices()
                                                .searchPlaces(value);

                                        allSearchResults
                                            .setResults(searchResults);
                                      } else {
                                        List<AutoCompleteResult> emptyList = [];
                                        allSearchResults.setResults(emptyList);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  searchFlag.searchToggle
                      ? allSearchResults.allReturnedResults.length != 0
                          ? Positioned(
                              top: 100,
                              left: 15,
                              child: Container(
                                height: 200,
                                width: screenWidth - 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                child: ListView(
                                  children: [
                                    ...allSearchResults.allReturnedResults.map(
                                        (e) => buildListItem(e, searchFlag))
                                  ],
                                ),
                              ),
                            )
                          : Positioned(
                              top: 100,
                              left: 15,
                              child: Container(
                                height: 200,
                                width: screenWidth - 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text("No results to show",
                                          style: TextStyle(
                                              fontFamily: "workSans",
                                              fontWeight: FontWeight.w200)),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 125,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            searchFlag.toggleSearch();
                                          },
                                          child: Center(
                                            child: Text(
                                              "Close this",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "WorkSans",
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ))
                      : Container()
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FabCircularMenuPlus(
          fabOpenIcon: Icon(Icons.add, color: Colors.white),
          fabCloseIcon: Icon(Icons.close, color: Colors.white),
          fabCloseColor: Colors.red.shade100, // Change to your desired color
          alignment: Alignment.bottomLeft,
          ringDiameter: 250.0,
          ringWidth: 60.0,
          ringColor: Colors.blue.shade50,
          fabSize: 60.0,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  searchToggle = true;
                  radiusSlider = false;
                  pressedNear = false;
                  cardTapped = false;
                  getDirections = false;
                });
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.navigation),
            ),
          ],
        ));
  }

  Future<void> gotoSearchedPLace(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );
  }

  Widget buildListItem(AutoCompleteResult placeItem, searchFlag) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: GestureDetector(
        onTapDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onTap: () async {
          var place = await MapServices().getPlace(placeItem.placeId);
          gotoSearchedPLace(place["geometry"]["location"]["lat"],
              place["geometry"]["location"]["lng"]);
          searchFlag.toggleSearch();
        },
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(Icons.location_on, color: Colors.green, size: 25),
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width - 75,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(placeItem.description ?? ""),
            ),
          )
        ]),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
