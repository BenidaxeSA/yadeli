"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.handlePaymentWebhook = exports.initiatePayment = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const commission_1 = require("./commission");
//import { creditDriverWallet } from './wallet';
admin.initializeApp();
const db = admin.firestore();
/**
 * 1. Appelé par l'App Flutter quand le client clique sur "Payer"
 */
exports.initiatePayment = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Non connecté');
    }
    const { orderId, amount, phoneNumber, orderType } = request.data;
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
});
/**
 * 2. Webhook reçu d'Airtel / MTN quand le client a tapé son PIN
 */
exports.handlePaymentWebhook = (0, https_1.onRequest)(async (req, res) => {
    var _a;
    const { transactionId, status } = req.body;
    if (!transactionId) {
        res.status(400).send('Missing transactionId');
        return;
    }
    if (status === 'SUCCESS') {
        const txnRef = db.collection('transactions').doc(transactionId);
        const txnDoc = await txnRef.get();
        if (txnDoc.exists && ((_a = txnDoc.data()) === null || _a === void 0 ? void 0 : _a.status) === 'PENDING') {
            const data = txnDoc.data();
            // A. Calcul des parts
            const split = (0, commission_1.calculateSplit)(data.amount, data.orderType);
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
});
//# sourceMappingURL=mobile_money.js.map