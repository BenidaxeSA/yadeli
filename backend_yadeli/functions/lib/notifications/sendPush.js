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
exports.sendPushToDriver = void 0;
const admin = __importStar(require("firebase-admin"));
/**
 * Envoie une notification push à un livreur ou à tous les livreurs
 */
const sendPushToDriver = async (driverId, title, body) => {
    var _a;
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
    const fcmToken = (_a = driverDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
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
exports.sendPushToDriver = sendPushToDriver;
//# sourceMappingURL=sendPush.js.map