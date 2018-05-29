/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
/**
 * Write your transction processor functions here
 */

/**
 * A drug has been produced by the manufacturer
 * @param {org.howest.mydrugchain.DrugItemProduction} drugProduction
 * @transaction
 */
async function registerDrugProduction(drugProduction) {
    let factory = getFactory();
    let NS = 'org.howest.mydrugchain';

    //create new asset
    let assetRegistry = await getAssetRegistry('org.howest.mydrugchain.Drug');

    let drugAsset = factory.newResource(NS, 'Drug', drugProduction.serialNumber);
    drugAsset.productCode = drugProduction.productCode;
    drugAsset.batchNumber = drugProduction.batchNumber;
    drugAsset.productHash = hash(drugProduction.serialNumber+drugProduction.productCode+drugProduction.batchNumber+drugProduction.manufacturer.actorId);//sha256(drugProduction.serialNumber+drugProduction.productCode+drugProduction.batchNumber);
    drugAsset.manufacturer = factory.newRelationship(NS, 'Manufacturer', drugProduction.manufacturer.getIdentifier());

    await assetRegistry.add(drugAsset)
}

/**
 * A drug has been received by a party in the chain
 * @param {org.howest.mydrugchain.Reception} reception
 * @transaction
 */
async function receiveDrug(reception) {
    let factory = getFactory();
    let NS = 'org.howest.mydrugchain';

    //verify metadata by checking hash attribute
    let checkHash = hash(reception.serialNumber+reception.productCode+reception.batchNumber+reception.manufacturerId);
    let assetRegistry = await getAssetRegistry('org.howest.mydrugchain.Drug');
    let asset = await assetRegistry.get(reception.serialNumber);

    let trxRegistry = await getTransactionRegistry('org.howest.mydrugchain.Reception');

    if (asset.productHash === checkHash && asset.quarantinePlacement == null) {
        let reception = factory.newResource(NS, 'Reception',trxId );
        reception.receptionDate = verification.receptionDate;
        reception.originatingParty = factory.newRelationship(NS, verification.originatingType, verification.originatingParty.getIdentifier());
        reception.receivingParty = factory.newRelationship(NS, verification.receivingType, verification.receivingParty.getIdentifier());
        reception.drug = factory.newRelationship(NS, 'Drug', asset.serialNumber);
        let trxRegistry = await getTransactionRegistry('org.howest.mydrugchain.Reception');
        await trxRegistry.add(reception);

    } else {
        let quarantine = factory.newConcept(NS, 'QuarantinePlacement');
        quarantine.start = reception.receptionDate;
        quarantine.reason = 'provided data do not match with hash!';
        asset.quarantinePlacement = quarantine;
        await assetRegistry.update(asset);
    }


    
}



//just a simple hash function (e.g. could be replaced by SHA-2/3)
var hash = function(s) {
    var a = 1, c = 0, h, o;
    if (s) {
        a = 0;
        /*jshint plusplus:false bitwise:false*/
        for (h = s.length - 1; h >= 0; h--) {
            o = s.charCodeAt(h);
            a = (a<<6&268435455) + o + (o<<14);
            c = a & 266338304;
            a = c!==0?a^c>>21:a;
        }
    }
    return String(a);
};

//just a basic guid function
// var guid = function () {
//     function s4() {
//       return Math.floor((1 + Math.random()) * 0x10000)
//         .toString(16)
//         .substring(1);
//     }
//     return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
//   }
