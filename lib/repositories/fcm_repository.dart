import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:meubitcoin/models/fcm.dart';

class FcmRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String coll = "fcm";

  CollectionReference getCollRef() => _firebaseFirestore.collection(coll);

  Future<List<QueryDocumentSnapshot>> all() async {
    var snap = await getCollRef().get();
    return snap.docs;
  }

  Future<List<Fcm>> getByIdDevice(String idDevice) async {
    var snap = await getCollRef().where("id_device", isEqualTo: idDevice).get();
    return snap.docs.map((e) => Fcm.fromSnap(e)).toList();
  }

  Future<List<Fcm>> getByCoinIdDevice(
      {required String idDevice, required String coin}) async {
    var snap = await getCollRef()
        .where("id_device", isEqualTo: idDevice)
        .where("coin", isEqualTo: coin)
        .get();
    return snap.docs.map((e) => Fcm.fromSnap(e)).toList();
  }

  Future<List<Fcm>> getAll() async {
    var snap = await getCollRef().get();
    return snap.docs.map((e) => Fcm.fromSnap(e)).toList();
  }

  Future<Fcm> get(String id) async {
    var snap = await getCollRef().doc("${id}").get();
    return Fcm.fromSnap(snap);
  }

  Future<Fcm> add(Fcm fcm) async {
    var json = fcm.toJson();
    json.remove("id");
    var snap = await getCollRef().add(json);
    return Fcm.fromSnap(await snap.get());
  }

  Future<Fcm> put({required Fcm fcm, required String id}) async {
    var docRef = getCollRef().doc("${id}");
    if (!(await docRef.get()).exists) throw Exception("Id not found.");
    var json = fcm.toJson();
    json.remove("id");
    await docRef.set(json);
    return Fcm.fromSnap(await docRef.get());
  }

  Future<bool> remove(String? id) async {
    var docRef = getCollRef().doc("${id}");
    if (!(await docRef.get()).exists) return false;
    await docRef.delete();
    return true;
  }
}
