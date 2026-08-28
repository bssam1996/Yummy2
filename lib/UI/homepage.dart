import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/recipe.dart';
import '/UI/Recipe/add_edit_recipe.dart';
import '/UI/Recipe/list_of_recipes.dart';
import '/UI/not_logged_user.dart';
import '/shared/snack.dart';
import 'package:page_transition/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Authentication/auth.dart';
import '../configurations/configurations.dart';
import '../contact_page.dart';
import '../models/user.dart';
import 'Authentication/login_page.dart';
import 'PublicRecipes/view_public_recipes.dart';
import 'Recipe/search_recipes.dart';
import 'UserProfile/qr_code_page.dart';
import '../shared/constants.dart';
class HomePageClass extends StatefulWidget {
  CustomUser? customUser;
  HomePageClass({Key? key, this.customUser}) : super(key: key);

  @override
  State<HomePageClass> createState() => _HomePageClassState();
}

class _HomePageClassState extends State<HomePageClass> {
  final AuthService? _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountEmail: null,
      currentAccountPicture: CircleAvatar(
        child: Image.asset(
          'assets/icons/main.png',
          width: 512.0,
          height: 512.0,
        ),
        backgroundColor: const Color(0xFF303A5D),
      ),
      accountName: Text(Configurations().globalAppName,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
      decoration: BoxDecoration(
        color: purpleColor
      ),
    );
    final drawerItems =ListView(
      children: [
        drawerHeader,
        Column(
          children: [
            ListTile(
              title: const Text("Public Recipes"),
              onTap: (){
                Navigator.push(context, PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.fade,
                    child: ViewPublicRecipesClass(customUser: widget.customUser)
                ));
              },
              trailing: const FaIcon(
                  FontAwesomeIcons.networkWired,
                  color: Colors.teal,
                size: 18,
              ),
            ),
            const Divider(),
          ],
        ),
        Visibility(
          visible: widget.customUser != null,
          child: Column(
            children: [
              ListTile(
                title: const Text("My Info"),
                onTap: (){
                  Navigator.push(context, PageTransition(
                      curve: Curves.linear,
                      type: PageTransitionType.fade,
                      child: userQRPage(customUser: widget.customUser)
                  ));
                },
                trailing: const FaIcon(
                  FontAwesomeIcons.idBadge,
                  color: Colors.indigo
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        ListTile(
          title: const Text("Contact"),
          onTap: (){
            Navigator.push(context, PageTransition(
                curve: Curves.linear,
                alignment: Alignment.topCenter,
                type: PageTransitionType.scale,
                child: const ContactPageClass())
            );
          },
          trailing: const FaIcon(
              FontAwesomeIcons.addressBook,
              color: Colors.amber,
          ),
        ),
        const Divider(),
        Visibility(
          visible: widget.customUser != null,
          child: ListTile(
            title: const Text("Logout"),
            onTap: () async{
              try{
                dynamic result = await _auth?.signOut();
              }catch (error){
                ScaffoldMessenger.of(context).showSnackBar(snack().displaySnackBar("Couldn't logout due to " + error.toString(),Colors.red));
              }
            },
            trailing: const FaIcon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.red,
            ),
          ),
        ),
        Visibility(
          visible: widget.customUser == null,
          child: ListTile(
            title: const Text("Login"),
            onTap: () async{
              Navigator.push(context, PageTransition(
                  curve: Curves.linear,
                  alignment: Alignment.topCenter,
                  type: PageTransitionType.scale,
                  child: LoginPage())
              );
            },
            trailing: const FaIcon(
                FontAwesomeIcons.signInAlt,
                color: Colors.green,
            ),
          ),
        ),
      ],
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: Text(Configurations().globalAppName, style: TextStyle(color:Colors.white),),
          backgroundColor: darkBlue,
          actions: [
            Visibility(
              visible: widget.customUser != null,
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                      var r = FirebaseFirestore.instance.collection('Users').doc(widget.customUser?.uid).collection("recipes")
                          .orderBy("Created",descending: true).get().then((snapshot) {
                        List<Recipe> recipes;
                        recipes = [];
                        int snapshotLength = snapshot.docs.length;
                        for(int snapIndex = 0; snapIndex < snapshotLength; snapIndex++){
                          Recipe recipe = Recipe(
                            id: snapshot.docs.elementAt(snapIndex).id,
                            sharing: (snapshot.docs.elementAt(snapIndex).data() as Map)["Sharing"]?.toString()??"",
                            created: (snapshot.docs.elementAt(snapIndex).data() as Map)["Created"].toDate(),
                            type:(snapshot.docs.elementAt(snapIndex).data() as Map)["Type"]?.toString()??"",
                            title:(snapshot.docs.elementAt(snapIndex).data() as Map)["Title"]?.toString()??"",
                            description:(snapshot.docs.elementAt(snapIndex).data() as Map)["Description"]?.toString()??"",
                            ingredients:(snapshot.docs.elementAt(snapIndex).data() as Map)["Ingredients"]?.toString()??"",
                            directions:(snapshot.docs.elementAt(snapIndex).data() as Map)["Directions"]?.toString()??"",
                            numberOfMinutes:(snapshot.docs.elementAt(snapIndex).data() as Map)["NumberOfMinutes"]??0,
                            ovenTemp:(snapshot.docs.elementAt(snapIndex).data() as Map)["OvenTemp"]??0,
                            servings:(snapshot.docs.elementAt(snapIndex).data() as Map)["Servings"]??0,
                            notes:(snapshot.docs.elementAt(snapIndex).data() as Map)["Notes"]?.toString()??"",
                            videos:(snapshot.docs.elementAt(snapIndex).data() as Map)["videos"]??[]
                          );
                          recipes.add(recipe);
                        }
                        showSearch(
                            context: context,
                            delegate: SearchRecipesClass(
                              customUser: widget.customUser,
                              listExample: recipes,
                              editable: true
                            ));
                      });

                      }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(context, PageTransition(
              curve: Curves.linear,
              alignment: Alignment.topCenter,
              type: PageTransitionType.scale,
              child: AddEditRecipe(method: "Create",customUser: widget.customUser,recipe: null,))
          );},
          child: const ListTile(
            title: Icon(Icons.add, color: Colors.white,),
          ),
          backgroundColor: purpleColor,
        ),
        drawer: Drawer(
          child: drawerItems,
        ),
        body: widget.customUser == null?const NotLoggedUserHomeClass():ListOfRecipesClass(customUser:widget.customUser),
      ),
    );
  }

  void showSuccessDialog({required BuildContext context,required String title,required String msg}) {
    // AwesomeDialog(
    //   context: context,
    //   dialogType: DialogType.SUCCES,
    //   animType: AnimType.SCALE,
    //   headerAnimationLoop: false,
    //   showCloseIcon: true,
    //   title: title,
    //   desc: msg,
    // ).show();
    EasyLoading.showSuccess("Success");
  }
}
