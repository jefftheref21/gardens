from pymongo import MongoClient
from mongoengine import Document, StringField, IntField, ListField, ReferenceField, DateTimeField, connect
from bson import ObjectId
from dotenv import load_dotenv
import os
import certifi

ca = certifi.where()
class Database():
    baseAddress = ''
    def __init__(self) -> None:
        load_dotenv()
        mongo_uri = os.getenv("MONGO_URI")
        self.client = MongoClient(host=mongo_uri, tlsCAFile=ca)
        self.db = self.client['gardens']
        self.plants = self.db['plants']
        self.users = self.db['users']
        self.comments = self.db['comments']
        self.gardens = self.db['gardens']

    # Using indexes to search for plants by gardenID
    def get_all_plants_by_gardenID(self, gardenID):
        plants = self.plants.find({"gardenID": ObjectId(gardenID)})
        return plants

    def add_plant(self, gardenID, name, imageUrl, description):
        plant = {"gardenID": ObjectId(gardenID), "name": name, "imageUrl": imageUrl, "description": description}
        self.plants.insert_one(plant)
        id = self.plants.find_one({"gardenID": ObjectId(gardenID), "name": name, "imageUrl": imageUrl,})["_id"]
        return id

    def update_plant(self, plantID, name, imageUrl, description):
        self.plants.update_one(
            {"_id": ObjectId(plantID)},
            {"$set": {"name": name, "imageUrl": imageUrl, "description": description}}
        )
    
    def delete_plant(self, plantID):
        self.plants.delete_one({"_id": ObjectId(plantID)})

    def create_index(self, field):
        self.plants.create_index(field)

    def get_plant_by_id(self, plantID):
        plant = self.plants.find_one({"_id": ObjectId(plantID)})
        return plant
    
    def get_plant_by_name(self, name):
        plant = self.plants.find_one({"name": name})
        return plant
    
    def get_all_users(self):
        users = self.users.find({})
        return users
    
    def add_user(self, username, password):
        user = {"username": username, "password": password}
        self.users.insert_one(user)
        id = self.users.find_one({"username": username})["_id"]
        return id
    
    def update_user(self, userID, username, password):
        self.users.update_one(
            {"_id": ObjectId(userID)},
            {"$set": {"username": username, "password": password}}
        )

    def get_all_gardens(self):
        gardens = self.gardens.find({})
        return gardens
    
    def add_garden(self, name, description, imageUrl, location):
        garden = {"name": name, "description": description,
                  "imageUrl": imageUrl, "location": location}
        self.gardens.insert_one(garden)
        id = self.gardens.find_one({"name": name})["_id"]
        return id
    
    def update_garden(self, gardenID, name, description):
        self.gardens.update_one(
            {"_id": ObjectId(gardenID)},
            {"$set": {"name": name, "description": description}}
        )

    def delete_garden(self, gardenID):
        self.gardens.delete_one({"_id": ObjectId(gardenID)})

    def delete_all(self):
        self.plants.delete_many({})
        self.users.delete_many({})
        self.comments.delete_many({})
        self.gardens.delete_many({})

class Gardens(Document):
    name = StringField(required=True)
    description = StringField()
    imageUrl = StringField()
    location = StringField()

class Plants(Document):
    gardenID = ReferenceField(Gardens, reverse_delete_rule=4)
    name = StringField(required=True)
    imageUrl = StringField()
    description = StringField()

if __name__ == '__main__':
    db = Database()
    # plants = db.get_all_plants()
    # print(plants[0])
    db.delete_all()

    gardenID1 = db.add_garden(name="Garden 1", description="Heavenly", imageUrl="garden1.png", location="123 Main St")
    gardenID2 = db.add_garden(name="Garden 2", description="Beautiful", imageUrl="garden2.png", location="456 Side St")

    db.add_plant(gardenID=gardenID1, name="Rosemary", imageUrl="rosemary.png", description="A fragrant herb used in cooking.")
    db.add_plant(gardenID=gardenID1, name="Thyme", imageUrl="thyme.png", description="A versatile herb with a strong flavor.")
    db.add_plant(gardenID=gardenID1, name="Cherry Tree", imageUrl="cherry_tree.png", description="A tree that produces sweet cherries.")
    db.add_plant(gardenID=gardenID1, name="Indica Flower", imageUrl="indica_flower.png", description="A flowering plant known for its relaxing properties.")
    db.add_plant(gardenID=gardenID1, name="Saffron", imageUrl="saffron.png", description="A spice derived from the flower of Crocus sativus.")

    db.add_plant(gardenID=gardenID2, name="Tulip", imageUrl="tulip.png", description="A bulbous spring perennial flower.")
    db.add_plant(gardenID=gardenID2, name="Daisy", imageUrl="daisy.png", description="A common flowering plant with white petals and a yellow center.")
    db.add_plant(gardenID=gardenID2, name="Rose", imageUrl="rose.png", description="A woody perennial flowering plant of the genus Rosa.")
    db.add_plant(gardenID=gardenID2, name="Lily", imageUrl="lily.png", description="A flowering plant with large, prominent flowers.")
    db.add_plant(gardenID=gardenID2, name="Daffodil", imageUrl="daffodil.png", description="A spring perennial flower with a trumpet-shaped structure.")

    load_dotenv()
    mongo_orm_uri = os.getenv("MONGO_ORM_URI")
    connect(host=mongo_orm_uri)

    garden3 = Gardens(name="Italian Heaven", description="A collection of miniature trees.", imageUrl="bonsai.png", location="789 Bonsai St")
    garden3.save()

    tomato = Plants(gardenID=garden3, name="Tomato", imageUrl="tomato.png", description="A red fruit used in salads and sauces.")
    basil = Plants(gardenID=garden3, name="Basil", imageUrl="basil.png", description="A fragrant herb used in cooking.")
    mint = Plants(gardenID=garden3, name="Mint", imageUrl="mint.png", description="A refreshing herb used in drinks and desserts.")
    garlic = Plants(gardenID=garden3, name="Garlic", imageUrl="garlic.png", description="A pungent bulb used in cooking.")
    onion = Plants(gardenID=garden3, name="Onion", imageUrl="onion.png", description="A bulbous vegetable used in cooking.")

    tomato.save()
    basil.save()
    mint.save()
    garlic.save()
    onion.save()

    garden4 = Gardens(name="Cactus Garden", description="A collection of desert plants.", imageUrl="cactus.png", location="321 Cactus Ave")
    garden4.save()

    cactus = Plants(gardenID=garden4, name="Cactus", imageUrl="cactus.png", description="A succulent plant adapted to arid environments.")
    aloe_vera = Plants(gardenID=garden4, name="Aloe Vera", imageUrl="aloe_vera.png", description="A succulent plant known for its medicinal properties.")
    agave = Plants(gardenID=garden4, name="Agave", imageUrl="agave.png", description="A succulent plant used to make tequila.")
    prickly_pear = Plants(gardenID=garden4, name="Prickly Pear", imageUrl="prickly_pear.png", description="A cactus with edible fruit.")
    yucca = Plants(gardenID=garden4, name="Yucca", imageUrl="yucca.png", description="A plant with sword-like leaves and edible roots.")

    cactus.save()
    aloe_vera.save()
    agave.save()
    prickly_pear.save()
    yucca.save()

    # Find a garden
    garden = Gardens.objects(name="Cactus Garden").first()

    # Get all plants in that garden
    plants = Plants.objects(gardenID=garden)

    for plant in plants:
        print(plant.name, plant.imageUrl, plant.description)

    db.plants.create_index([("gardenID", 1)], name='plant_index')

    plants = db.plants.find({"gardenID": gardenID1})
    for plant in plants:
        print(plant["name"], plant["imageUrl"], plant["description"])

    explanation = db.plants.find({ "gardenID": gardenID1 }).explain()

    import pprint
    pprint.pprint(explanation)

    # db.add_user("jeffrey", "password")
    # db.add_user("molly", "password")
    # db.delete_plant("Tree")