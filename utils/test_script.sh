echo "verifying network..."
composer network ping --card admin@drug_chain
echo "create manufacturer"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.Manufacturer",
   "actorId": "man001",
   "name": "drug_man"
 }' 'http://localhost:3000/api/Manufacturer'

echo "create distributor"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.Distributor",
   "actorId": "dis001",
   "name": "drug_dis"
 }' 'http://localhost:3000/api/Distributor'

echo "create pharmacist"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.Pharmacist",
   "actorId": "pha001",
   "name": "apo"
 }' 'http://localhost:3000/api/Pharmacist'

echo "create patient"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.Patient",
   "actorId": "pat001",
   "name": "Jos"
 }' 'http://localhost:3000/api/Patient'

echo "post a drug production transaction"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.DrugItemProduction",
   "serialNumber": "one1",
   "productCode": "two2",
   "batchNumber": "three3",
   "manufacturer": "resource:org.howest.mydrugchain.Manufacturer#man001",
   "timestamp": "2018-05-24T19:32:40.604Z"
 }' 'http://localhost:3000/api/DrugItemProduction'

echo "post a drug transfer transaction (shipment)"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.DrugTransfer",
   "drug": "resource:org.howest.mydrugchain.Drug#one1",
   "newOwner": "resource:org.howest.mydrugchain.Distributor#dis001",
   "timestamp": "2018-05-31T19:14:01.629Z"
 }' 'http://localhost:3000/api/DrugTransfer'

echo "check drug details (i.e.owner)"
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/one1'

echo "post an invalid reception transaction: invoking party is not the designated owner of the asset"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.Reception",
   "serialNumber": "one1",
   "productCode": "two2",
   "batchNumber": "three3",
   "manufacturerId": "man001",
   "timestamp": "2018-05-31T19:25:21.576Z"
 }
 ' 'http://localhost:3000/api/Reception'
echo "post an invalid reception transaction: transaction does not contain the correct meta data"
echo "create a distributor user"
composer identity issue -c admin@drug_chain -f dis001.card -u dis001 -a "resource:org.howest.mydrugchain.Distributor#dis001"
composer card import --file dis001.card
composer transaction submit --card dis001@drug_chain -d '{
  "$class": "org.howest.mydrugchain.Reception",
  "serialNumber": "one1",
  "productCode": "two3",
  "batchNumber": "three3",
  "manufacturerId": "man001",
  "timestamp": "2018-05-31T19:25:21.576Z"
}'
echo "check drug details (i.e.quarantine)"
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/one1'

echo "post an invalid reception transaction: Drug was already placed in quarantine"
composer transaction submit --card dis001@drug_chain -d '{
  "$class": "org.howest.mydrugchain.Reception",
  "serialNumber": "one1",
  "productCode": "two2",
  "batchNumber": "three3",
  "manufacturerId": "man001",
  "timestamp": "2018-05-31T19:25:21.576Z"
}'

echo "post a valid reception transaction: invoking party is the designated owner of the asset and transaction contains the correct meta data"

echo "post a new drug production transaction"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.DrugItemProduction",
   "serialNumber": "three3",
   "productCode": "two2",
   "batchNumber": "three3",
   "manufacturer": "resource:org.howest.mydrugchain.Manufacturer#man001",
   "timestamp": "2018-06-24T19:32:40.604Z"
 }' 'http://localhost:3000/api/DrugItemProduction'

echo "post a new drug transfer transaction (shipment)"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
   "$class": "org.howest.mydrugchain.DrugTransfer",
   "drug": "resource:org.howest.mydrugchain.Drug#three3",
   "newOwner": "resource:org.howest.mydrugchain.Distributor#dis001",
   "timestamp": "2018-06-31T19:14:01.629Z"
 }' 'http://localhost:3000/api/DrugTransfer'

echo "post a valid reception transaction
composer transaction submit --card dis001@drug_chain -d '{
  "$class": "org.howest.mydrugchain.Reception",
  "serialNumber": "three3",
  "productCode": "two2",
  "batchNumber": "three3",
  "manufacturerId": "man001",
  "timestamp": "2018-06-31T19:25:21.576Z"
}'

echo "check drug details (i.e.not in quarantine)"
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/three3'

echo "some basic permissions examples"
echo "only manufacturer is allowed to register a drug production"
composer transaction submit --card dis001@drug_chain -d '{
  "$class": "org.howest.mydrugchain.DrugItemProduction",
   "serialNumber": "four4",
   "productCode": "two2",
   "batchNumber": "three3",
   "manufacturer": "resource:org.howest.mydrugchain.Manufacturer#man001",
   "timestamp": "2018-06-24T19:32:40.604Z"
}'
echo "only owner is allowed to update the asset"
echo "create a pharmacist user"
composer identity issue -c admin@drug_chain -f pha001.card -u pha001 -a "resource:org.howest.mydrugchain.Pharmacist#pha001"
composer card import --file pha001.card
echo "attempt to transfer the drugs"
composer transaction submit --card pha001@drug_chain -d '{
   "$class": "org.howest.mydrugchain.DrugTransfer",
   "drug": "resource:org.howest.mydrugchain.Drug#three3",
   "newOwner": "resource:org.howest.mydrugchain.Pharmacist#pha001",
   "timestamp": "2018-06-31T19:14:01.629Z"
}'

echo "patient can not transfer drugs"
echo "create a patient user"
composer identity issue -c admin@drug_chain -f pat001.card -u pat001 -a "resource:org.howest.mydrugchain.Patient#pat001"
composer card import --file pat001.card
echo "attempt to transfer the drugs to the patient"
composer transaction submit --card pat001@drug_chain -d '{
   "$class": "org.howest.mydrugchain.DrugTransfer",
   "drug": "resource:org.howest.mydrugchain.Drug#three3",
   "newOwner": "resource:org.howest.mydrugchain.Patient#pat001",
   "timestamp": "2018-06-31T19:14:01.629Z"
}'





