// Définit les règles de commission
export const COMMISSION_RATES = {
    PHARMACIE: 0.25, // 25%
    STANDARD: 0.15   // 15%
};

export interface RevenueSplit {
    platformFee: number; // Ta part
    driverShare: number; // Part du livreur
}

export const calculateSplit = (amount: number, type: 'pharmacie' | 'colis' | 'autre'): RevenueSplit => {
    const rate = type === 'pharmacie' ? COMMISSION_RATES.PHARMACIE : COMMISSION_RATES.STANDARD;
    
    // On arrondit pour éviter les décimales bizarres
    const platformFee = Math.round(amount * rate);
    const driverShare = amount - platformFee;

    return { platformFee, driverShare };
};