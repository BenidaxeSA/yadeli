import * as admin from 'firebase-admin';

/**
 * Envoie une notification push à un livreur ou à tous les livreurs
 */
export const sendPushToDriver = async (
  driverId: string,
  title: string,
  body: string
): Promise<void> => {

  const messaging = admin.messaging();
  const db = admin.firestore();

  // Cas 1 : broadcast à tous les livreurs
  if (driverId === 'ALL_DRIVERS') {
    await messaging.send({
      topic: 'drivers_brazza',
      notification: {
        title,
        body
      }
    });
    return;
  }

  // Cas 2 : notification ciblée
  const driverDoc = await db.collection('users').doc(driverId).get();

  if (!driverDoc.exists) {
    console.warn(`Driver ${driverId} introuvable`);
    return;
  }

  const fcmToken = driverDoc.data()?.fcmToken as string | undefined;

  if (!fcmToken) {
    console.warn(`Aucun token FCM pour le driver ${driverId}`);
    return;
  }

  await messaging.send({
    token: fcmToken,
    notification: {
      title,
      body
    }
  });
};
