import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { sendPushToDriver } from '../notifications/sendPush.js';
import { creditDriverWallet } from '../finance/wallet';
import { calculateSplit } from '../finance/commission';

admin.initializeApp();
//const db = admin.firestore();

/**
 * Trigger déclenché à chaque mise à jour d'une commande
 */
export const onOrderUpdated = onDocumentUpdated(
  'orders/{orderId}',
  async (event) => {
    const oldData = event.data?.before.data();
    const newData = event.data?.after.data();

    if (!oldData || !newData) return;

    const orderId = event.params.orderId;

    /**
     * SCÉNARIO 1 : Le client vient de payer
     * PENDING -> PAID
     */
    if (oldData.status !== 'PAID' && newData.status === 'PAID') {
      console.log(`✅ Commande ${orderId} payée. Recherche de livreurs...`);

      // Vérifie que ref existe avant de mettre à jour
      const ref = event.data?.after?.ref;
      if (ref) {
        await ref.update({ status: 'SEARCHING_DRIVER' });
      } else {
        console.warn(`Ref introuvable pour la commande ${orderId}`);
      }

      // Notification broadcast aux livreurs
      await sendPushToDriver(
        'ALL_DRIVERS',
        'Nouvelle course disponible !',
        `Gagnez ${Math.round(newData.amount * 0.85)} XAF maintenant.`
      );
    }

    /**
     * SCÉNARIO 2 : Course terminée
     * DELIVERED -> COMPLETED
     */
    if (oldData.status !== 'COMPLETED' && newData.status === 'COMPLETED') {
      const driverId = newData.driverId;
      if (!driverId) return;

      // Calcul des parts
      const split = calculateSplit(newData.amount, newData.type);

      // Crédit du wallet chauffeur
      await creditDriverWallet(
        driverId,
        split.driverShare,
        split.platformFee,
        orderId
      );

      // Notification chauffeur
      await sendPushToDriver(
        driverId,
        'Course terminée',
        `+${split.driverShare} XAF ajoutés à votre wallet.`
      );
    }
  }
);
