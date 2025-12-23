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
exports.onOrderUpdated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
const sendPush_js_1 = require("../notifications/sendPush.js");
const wallet_1 = require("../finance/wallet");
const commission_1 = require("../finance/commission");
admin.initializeApp();
//const db = admin.firestore();
/**
 * Trigger déclenché à chaque mise à jour d'une commande
 */
exports.onOrderUpdated = (0, firestore_1.onDocumentUpdated)('orders/{orderId}', async (event) => {
    var _a, _b, _c, _d;
    const oldData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.before.data();
    const newData = (_b = event.data) === null || _b === void 0 ? void 0 : _b.after.data();
    if (!oldData || !newData)
        return;
    const orderId = event.params.orderId;
    /**
     * SCÉNARIO 1 : Le client vient de payer
     * PENDING -> PAID
     */
    if (oldData.status !== 'PAID' && newData.status === 'PAID') {
        console.log(`✅ Commande ${orderId} payée. Recherche de livreurs...`);
        // Vérifie que ref existe avant de mettre à jour
        const ref = (_d = (_c = event.data) === null || _c === void 0 ? void 0 : _c.after) === null || _d === void 0 ? void 0 : _d.ref;
        if (ref) {
            await ref.update({ status: 'SEARCHING_DRIVER' });
        }
        else {
            console.warn(`Ref introuvable pour la commande ${orderId}`);
        }
        // Notification broadcast aux livreurs
        await (0, sendPush_js_1.sendPushToDriver)('ALL_DRIVERS', 'Nouvelle course disponible !', `Gagnez ${Math.round(newData.amount * 0.85)} XAF maintenant.`);
    }
    /**
     * SCÉNARIO 2 : Course terminée
     * DELIVERED -> COMPLETED
     */
    if (oldData.status !== 'COMPLETED' && newData.status === 'COMPLETED') {
        const driverId = newData.driverId;
        if (!driverId)
            return;
        // Calcul des parts
        const split = (0, commission_1.calculateSplit)(newData.amount, newData.type);
        // Crédit du wallet chauffeur
        await (0, wallet_1.creditDriverWallet)(driverId, split.driverShare, split.platformFee, orderId);
        // Notification chauffeur
        await (0, sendPush_js_1.sendPushToDriver)(driverId, 'Course terminée', `+${split.driverShare} XAF ajoutés à votre wallet.`);
    }
});
//# sourceMappingURL=onOrderUpdated.js.map