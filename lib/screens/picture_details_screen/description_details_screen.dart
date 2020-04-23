import 'dart:io';

import 'package:bear_grylls/services/animal_discovery.dart';
import 'package:bear_grylls/services/description_classifier.dart';
import 'package:bear_grylls/services/microsoft_species_classifier.dart';
import 'package:bear_grylls/services/plant_discovery.dart';
import 'package:bear_grylls/services/species_classifier_adaptor.dart';
import 'package:flutter/material.dart';

import '../../widgets/box_container.dart';

class DescriptionDetailsScreen extends StatefulWidget {
  final String description;

  DescriptionDetailsScreen({Key key, @required this.description}) : super(key: key);

  @override
  _DescriptionDetailsScreenState createState() => _DescriptionDetailsScreenState();
}

class _DescriptionDetailsScreenState extends State<DescriptionDetailsScreen> {

  String animalName = "";
  String kingdomName = "";
  String animalDetails = "";
  Future<void> _initializeDetailsFuture;
  bool _detailsAreInitialized;

  void _getAnimalName(String description) async {
    SpeciesClassifierAdaptor speciesClassifier = MicrosoftSpeciesClassifier();
    //var animalDetails = await speciesClassifier.getSpecies(description);
    var words = description.split(" ");
    print(words);
    Map descriptionMap = Map();
    descriptionMap['kingdom'] = 'animal';
    if (words.contains('plant')) {
      descriptionMap['kingdom'] = 'plants';
    }
    for (var i = 0; i <= words.length; i++) {
      if (words.contains('brown')) {
        descriptionMap['color'] = 'brown';
      }
      if (words.contains('white')) {
        descriptionMap['color'] = 'white';
      }
      if (words.contains('gray')) {
        descriptionMap['color'] = 'gray';
      }
      if (words.contains('green')) {
        descriptionMap['color'] = 'green';
      }
      if (words.contains('black')) {
        descriptionMap['color'] = 'black';
      }
    }
    DescriptionClassifier d = DescriptionClassifier();
    var animalDetails = d.getSpecies(descriptionMap);
    //var animalDetails = ["animals", "brown bear"];
    kingdomName = animalDetails[0];
    animalName = animalDetails[1];
  }

  void _getAnimalDetails(String animalName, String kingdomName) async {
    String lowerCaseKingdom = kingdomName.toLowerCase();
    if (lowerCaseKingdom == "animals") {
      animalDetails = await AnimalDiscovery().getFacts(animalName);
    } else if (lowerCaseKingdom == "plants") {
      animalDetails = await PlantDiscovery().getFacts(animalName);
    } else {
      print("No known kingdom name found; defaulting to Animals");
      animalDetails = await AnimalDiscovery().getFacts(animalName);
    }
  }

  Future<void> _initScreenInfo() async {
    await _getAnimalName(widget.description);
    if (animalName != "no name") {
      await _getAnimalDetails(animalName, kingdomName);
    }
    _detailsAreInitialized = true;
  }

  @override
  void initState() {
    super.initState();

    _detailsAreInitialized = false;
    _initializeDetailsFuture = _initScreenInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: FractionalOffset.center,
        children: <Widget>[

          //Positioned.fill(
            //child: Image.file(File(widget.imagePath)),
          //),

          FutureBuilder<void>(
            future: _initializeDetailsFuture,
            builder: (context, snapshot) {
              if (!_detailsAreInitialized) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Container(
                  alignment: FractionalOffset.center,
                  child: Stack(
                    children: <Widget>[

                      Positioned(
                        top: 40,
                        right: 30,
                        left: 30,
                        child: BoxContainer(
                          child: Center(
                            child: Text(
                              animalName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                                color: Colors.white
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          height: 100,
                          width: 300
                        ),
                      ),

                      Positioned(
                        bottom: 430,
                        left: 70,
                        right: 70,
                        child: BoxContainer(
                          width: 220,
                          height: 30,
                          child: Center(
                            child: Text(
                              "Details",
                              key: Key('details'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      ),

                      Positioned(
                        bottom: 30,
                        left: 30,
                        right: 30,
                        child: BoxContainer(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                animalDetails,
                                style: TextStyle(fontSize: 20, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ),
                          height: 390,
                          width: 300
                        ),
                      ),

                    ],
                  )
                );
              }
            },
          ),

        ],
      )
    );
  }
}