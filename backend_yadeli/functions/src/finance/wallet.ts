import * as admin from 'firebase-admin';

const db = admin.firestore();

// Crédite le portefeuille du livreur et enregistre ton CA
export const creditDriverWallet = async (driverId: string, driverShare: number, platformFee: number, orderId: string) => {
    const batch = db.batch();

    // 1. Mise à jour du Wallet Livreur (Atomic Increment)
    const walletRef = db.collection('wallets').doc(driverId);
    batch.set(walletRef, {
        balance: admin.firestore.FieldValue.increment(driverShare),
        totalEarned: admin.firestore.FieldValue.increment(driverShare),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    // 2. Enregistrement dans ton Grand Livre (Admin)
    const statsRef = db.collection('admin_stats').doc('revenue_current_month');
    batch.set(statsRef, {
        totalRevenue: admin.firestore.FieldValue.increment(platformFee),
        totalOrders: admin.firestore.FieldValue.increment(1)
    }, { merge: true });

    // 3. Historique de transaction pour audit
    const historyRef = walletRef.collection('history').doc();
    batch.set(historyRef, {
        type: 'CREDIT',
        amount: driverShare,
        orderId: orderId,
        date: admin.firestore.FieldValue.serverTimestamp()
    });

    await batch.commit();
    console.log(`💰 Wallet ${driverId} crédité de ${driverShare} XAF.`);
};