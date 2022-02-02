const { MongoClient } = require("mongodb");

const contractData = {
  temp_type: "article",
  template:
    "Hereby I $buyer, declare the purchase of $quantity units of $item for the ammount of $ammount SEK on $date from $owner. \nBuyer signature $buyersign \nSeller signature $sellersign",
};

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  throw new Error("DATABASE_URL must be set");
}

const DATABASE = "ChatDB";
const COLLECTION = "templates";
const client = new MongoClient(databaseUrl);

const createContract = async () => {
  await client.connect();
  console.log("Connected to MongoDB");

  const db = client.db(DATABASE);
  const collection = db.collection(COLLECTION);

  await collection.insertOne(contractData);

  console.log("Successfully created default contract");
};

createContract()
  .catch(console.error)
  .finally(() => client.close());
