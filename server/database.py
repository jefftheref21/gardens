from pymongo import MongoClient
# import bcrypt
# import ssl
from bson import ObjectId
import certifi

ca = certifi.where()
class Database():
    baseAddress = ''
    def __init__(self) -> None:
        # self.client = MongoClient("mongodb+srv://wujeffreyj:DMZTpy3PZWtiHI1E@gardens.qsiz96m.mongodb.net/")
        self.client = MongoClient("mongodb+srv://wujeffreyj:DMZTpy3PZWtiHI1E@gardens.qsiz96m.mongodb.net/?retryWrites=true&w=majority&appName=Gardens", tlsCAFile=ca)
        self.db = self.client['gardens']
        self.collection = self.db['plants']

    def get_all_plants(self):
        plants = self.collection.find({})
        return plants

    def add_plant(self, name, imageUrl):
        plant = {"name": name, "url": imageUrl}
        self.collection.insert_one(plant)
        id = self.collection.find_one({"name": name})["_id"]
        return id

    def update_plant(self, plantID, name, imageUrl):
        self.collection.update_one(
            {"_id": ObjectId(plantID)},
            {"$set": {"name": name, "url": imageUrl}}
        )
    
    def delete_plant(self, plantID):
        self.collection.delete_one({"_id": ObjectId(plantID)})

if __name__ == '__main__':
    db = Database()
    # plants = db.get_all_plants()
    # print(plants[0])
    db.add_plant("Rosemary", "rosemary.png")
    db.add_plant("Thyme", "thyme.png")
    db.add_plant("Cherry Tree", "cherry_tree.png")
    db.add_plant("Indica Flower", "indica_flower.png")
    db.add_plant("Saffron", "saffron.png")
    # db.delete_plant("Tree")