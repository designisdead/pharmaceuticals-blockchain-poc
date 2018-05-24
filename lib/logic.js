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
 * Sample transaction
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
    drugAsset.productHash = hash(drugProduction.serialNumber+drugProduction.productCode+drugProduction.batchNumber);//sha256(drugProduction.serialNumber+drugProduction.productCode+drugProduction.batchNumber);
    drugAsset.manufacturer = factory.newRelationship(NS, 'Manufacturer', drugProduction.manufacturer.getIdentifier());

    await assetRegistry.add(drugAsset)
}

//just a simple hash function (e.g. could be replaced by SHA-2/3)
var hash = function(s) {
    /* Simple hash function. */
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
