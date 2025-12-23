import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { calculateSplit } from './commission';
//import { creditDriverWallet } from './wallet';

admin.initializeApp();
const db = admin.firestore();

/**
 * Données reçues depuis Flutter
 */
interface InitiatePaymentData {
  orderId: string;
  amount: number;
  phoneNumber: string;
  orderType: 'pharmacie' | 'colis';
}

/**
 * 1. Appelé par l'App Flutter quand le client clique sur "Payer"
 */
export const initiatePayment = onCall(
  async (request) => {

    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'Non connecté'
      );
    }

    const {
      orderId,
      amount,
      phoneNumber,
      orderType
    } = request.data as InitiatePaymentData;

    const transactionRef = await db.collection('transactions').add({
      orderId,
      userId: request.auth.uid,
      amount,
      status: 'PENDING',
      provider: 'MOBILE_MONEY',
      phone: phoneNumber,
      orderType,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return {
      success: true,
      transactionId: transactionRef.id,
      paymentUrl: `https://api.airtel-money.com/fake-pay/${transactionRef.id}`
    };
  }
);

/**
 * 2. Webhook reçu d'Airtel / MTN quand le client a tapé son PIN
 */
export const handlePaymentWebhook = onRequest(
  async (req, res) => {

    const { transactionId, status } = req.body as {
      transactionId: string;
      status: 'SUCCESS' | 'FAILED';
    };

    if (!transactionId) {
      res.status(400).send('Missing transactionId');
      return;
    }

    if (status === 'SUCCESS') {
      const txnRef = db.collection('transactions').doc(transactionId);
      const txnDoc = await txnRef.get();

      if (txnDoc.exists && txnDoc.data()?.status === 'PENDING') {
        const data = txnDoc.data()!;

        // A. Calcul des parts
        const split = calculateSplit(data.amount, data.orderType);

        // B. Mise à jour transaction
        await txnRef.update({
          status: 'COMPLETED',
          driverShare: split.driverShare,
          platformFee: split.platformFee
        });

        // C. Mise à jour commande
        await db.collection('orders').doc(data.orderId).update({
          status: 'PAID',
          paymentId: transactionId
        });

        // Le wallet chauffeur sera crédité via un trigger Firestore
      }
    }

    res.status(200).send('OK');
  }
);
