
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Errors.dart';
import 'EventListFiltredPage.dart';
class FilterPage extends StatefulWidget {

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool underTenParticipansCondition = false, betweenTenTwentyParticipansCondition = false, overTwentyParticipansCondition = false;
  bool selectedStartDateIsSelected = false, selectedEndDateIsSelected = false;

  String buttonStartDateText = 'Selectează data de start';
  String buttonEndDateText = 'Selectează data de final';
  String selectedCounty = 'Alba';
  String selectedCategory = 'Niciuna';
  bool isCountySelected = false;
  bool isCategorySelected = false;


  GlobalKey<FormState> key = GlobalKey();

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Filtrare',
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/Color.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
              key: key,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Selecteaza Data ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(onPressed:(){
                            //do nothing
                          } ,
                              icon: Icon(Icons.calendar_today),
                          ),
                        ]
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime selectedStartDate = await _selectDate(context);
                        setState(() {
                          _selectedStartDate = selectedStartDate;
                          selectedStartDateIsSelected = true;
                          buttonStartDateText = 'Data de start: ${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}';
                          checkDateError();
                        });
                      },
                      child: Text(buttonStartDateText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: selectedStartDateIsSelected ? Colors.orangeAccent : null,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime selectedEndDate = await _selectDate(context);
                        setState(() {
                          _selectedEndDate = selectedEndDate;
                          selectedEndDateIsSelected = true;
                          buttonEndDateText = 'Data de final: ${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}';
                          checkDateError();
                        });
                      },
                      child: Text(buttonEndDateText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),),
                      style: ElevatedButton.styleFrom(
                        primary: selectedEndDateIsSelected ? Colors.orangeAccent : null,
                      ),
                    ),
                    Container(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Selecteaza Numar Participanti",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            color: Colors.black,
                          ),
                      ),
                        IconButton(onPressed:(){
                          //do nothing
                        } ,
                            icon: Icon(Icons.person)
                        )
                      ],
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              underTenParticipansCondition = true;
                              betweenTenTwentyParticipansCondition = false;
                              overTwentyParticipansCondition = false;
                            });
                          },
                          child: Text("<10",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),),
                          style: ElevatedButton.styleFrom(
                            primary: underTenParticipansCondition ? Colors.orangeAccent : null,
                          ),
                        ),
                        SizedBox(width: 10,),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              underTenParticipansCondition = false;
                              betweenTenTwentyParticipansCondition = true;
                              overTwentyParticipansCondition = false;
                            });
                          },
                          child: Text("10-20",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),),
                          style: ElevatedButton.styleFrom(
                            primary: betweenTenTwentyParticipansCondition ? Colors.orangeAccent : null,
                          ),
                        ),
                        SizedBox(width: 10,),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              underTenParticipansCondition = false;
                              betweenTenTwentyParticipansCondition = false;
                              overTwentyParticipansCondition = true;
                            });
                          },
                          child: Text(">20",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),),
                          style: ElevatedButton.styleFrom(
                            primary: overTwentyParticipansCondition ? Colors.orangeAccent : null,
                          ),
                        ),
                      ]
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Alege categorie ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(onPressed:(){
                            //do nothing
                          } ,
                              icon: Icon(Icons.category)
                          )
                        ],
                      ),
                    ),
                    /*Dropdown*/
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                              color: Colors.orangeAccent,
                              width: 3.0
                          ),
                        ),
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                              isCategorySelected = true;
                            });
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          dropdownColor: Colors.white,
                          items: <String>['Niciuna','Strategie', 'Zaruri', 'Gateway', 'Diverse','Toate Varstele','Party','Carti, Campionat'
                            ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Alege locatie ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(onPressed:(){
                            //do nothing
                          } ,
                              icon: Icon(Icons.map)
                          )
                        ],
                      ),
                    ),
                    /*Dropdown*/
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 3.0
                        ),
                      ),
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: DropdownButton<String>(
                        value: selectedCounty,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCounty = newValue!;
                            isCountySelected = true;
                          });
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        dropdownColor: Colors.white,
                        items: <String>[
                          'Alba', 'Arad', 'Argeș', 'Bacău', 'Bihor', 'Bistrița-Năsăud', 'Botoșani',
                          'Brăila', 'Brașov','București', 'Buzău', 'Călărași', 'Caraș-Severin',
                          'Cluj', 'Constanța', 'Covasna', 'Dâmbovița', 'Dolj', 'Galați', 'Giurgiu',
                          'Gorj', 'Harghita', 'Hunedoara', 'Ialomița', 'Iași', 'Ilfov', 'Maramureș',
                          'Mehedinți', 'Mureș', 'Neamț', 'Olt', 'Prahova', 'Satu Mare', 'Sălaj',
                          'Sibiu', 'Suceava', 'Teleorman', 'Timiș', 'Tulcea', 'Vâlcea', 'Vaslui',
                          'Vrancea'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ),
                    SizedBox(height: 30,),
                    ElevatedButton(
                        onPressed: (){
                          _navigateToEventListPage();
                        },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.5),
                        ),
                        elevation: 10.0,
                        side: BorderSide(
                          color: Colors.orangeAccent,
                          width: 3.0,
                        ),
                      ),
                      child: Container(
                        width: 80.0,
                        height: 50.0,
                        alignment: Alignment.center,
                        child: Text(
                          'Gata',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ]
                )
              )
            )
          )
        )
      ),
    );
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(data: ThemeData.light().copyWith(
            primaryColor: Colors.orangeAccent,
            colorScheme: ColorScheme.light(
              primary: Colors.orangeAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Color.fromRGBO(3, 220, 255, 50),
            ),
            textTheme: TextTheme(
              labelLarge: TextStyle(
                fontSize: 24,
              ),
            ),
          ), child: child!,
          );
        }
    ))!;

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
    return _selectedDate;
  }

  void checkDateError(){
    if(_selectedStartDate.isAfter(_selectedEndDate) && selectedEndDateIsSelected && selectedStartDateIsSelected )
      showSelectedDateError(context);
  }
  void _navigateToEventListPage() {
    if (_selectedStartDate != null &&
        _selectedEndDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventListFiltredPage(
            selectedStartDate: _selectedStartDate,
            selectedEndDate: _selectedEndDate,
            underTenParticipansCondition: underTenParticipansCondition,
            betweenTenTwentyParticipansCondition: betweenTenTwentyParticipansCondition,
            overTwentyParticipansCondition: overTwentyParticipansCondition,
            selectedCounty: selectedCounty,
            selectedCategory: selectedCategory,
          ),
        ),
      );
    } else {
        //Do nothing
    }
  }
}

