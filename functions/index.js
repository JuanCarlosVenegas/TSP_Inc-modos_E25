const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.updateOldPendingPickupRequests = functions.pubsub
    .schedule("every day 00:00")
    .onRun(async (context) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // midnight para comparar solo fechas

      const pickupRequestsRef = db.collection("pickup_requests");
      const snapshot = await pickupRequestsRef
          .where("status", "==", "Pendiente")
          .get();

      const batch = db.batch();

      snapshot.forEach((doc) => {
        const data = doc.data();
        const createdAt = data.createdAt.toDate();

        if (createdAt < today) {
          const docRef = pickupRequestsRef.doc(doc.id);
          batch.update(docRef, {status: "Sin recoger"});
        }
      });

      await batch.commit();
      console.log("Pickup requests actualizados");

      return null;
    });
