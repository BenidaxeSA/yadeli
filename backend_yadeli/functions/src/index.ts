import * as admin from 'firebase-admin';

// Initialisation unique
admin.initializeApp();

// Export des modules
// 1. Finance
export { initiatePayment, handlePaymentWebhook } from './finance/mobile_money';

// 2. Orders
// export { onOrderCreated } from './orders/onOrderCreated'; // Si besoin plus tard
export { onOrderUpdated } from './orders/onOrderUpdated';

// Ce fichier reste propre et ne contient pas de logique métier.