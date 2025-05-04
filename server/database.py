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
        try:
            gardenID = ObjectId(gardenID)
            plants = self.plants.find({"gardenID": gardenID})
            return plants
        except Exception:
            print(f"Error: Not a valid ObjectId: {gardenID}")
            return None

    def add_plant(self, gardenID, name, imageUrl, description):
        plant = {"gardenID": ObjectId(gardenID),
                 "name": name,
                 "imageUrl": imageUrl,
                 "description": description}
        # Sanitize input
        plant = self.sanitize_dict(plant)
        self.plants.insert_one(plant)
        id = self.plants.find_one({"gardenID": ObjectId(gardenID), "name": name, "imageUrl": imageUrl,})["_id"]
        return id

    def update_plant(self, plantID, name, imageUrl, description):
        plant = {"name": name,
                 "imageUrl": imageUrl,
                 "description": description}
        # Sanitize input
        plant = self.sanitize_dict(plant)
        try:
            plantID = ObjectId(plantID)
            self.plants.update_one(
                {"_id": plantID},
                {"$set": {"name": name, "imageUrl": imageUrl, "description": description}}
            )
        except Exception:
            print(f"Error: Not a valid ObjectId: {plantID}")
        
    
    def delete_plant(self, plantID):
        try:
            plantID = ObjectId(plantID)
            self.plants.delete_one({"_id": plantID})
        except Exception:
            print(f"Error: Not a valid ObjectId: {plantID}")

    def index_plant(self):
        db.plants.create_index([("gardenID", 1)], name='plants_in_garden_index')
        db.plants.create_index([("name", 1)], name='plant_name_index')

    def get_plant_by_id(self, plantID):
        try:
            plantID = ObjectId(plantID)
            plant = self.plants.find_one({"_id": plantID})
            return plant
        except Exception:
            print(f"Error: Not a valid ObjectId: {plantID}")
            return None
    
    def get_plant_by_name(self, name):
        ndict = {"name": name}
        # Sanitize input
        ndict = self.sanitize_input(ndict)
        plant = self.plants.find_one(ndict)
        return plant
    
    def get_all_users(self):
        users = self.users.find({})
        return users

    def add_user(self, username, name, email, phoneNumber, profilePicUrl, biography, gardenIDs):
        user = {"username": username,
                "name": name,
                "email": email,
                "phoneNumber": phoneNumber,
                "profilePicUrl": profilePicUrl,
                "biography": biography,
                "gardenIDs": gardenIDs}
        # Sanitize input
        user = self.sanitize_input(user)
        self.users.insert_one(user)
        id = self.users.find_one({"username": username},{"_id": 1})["_id"]
        return id
    
    def update_user(self, userID, username, name, email, phoneNumber, profilePicUrl, biography, gardenIDs):
        user = {"username": username,
                "name": name,
                "email": email,
                "phoneNumber": phoneNumber,
                "profilePicUrl": profilePicUrl,
                "biography": biography,
                "gardenIDs": gardenIDs}
        # Sanitize input
        user = self.sanitize_input(user)
        try:
            userID = ObjectId(userID)
            self.users.update_one(
                {"_id": userID},
                {"$set": {**user}}
            )
        except Exception:
            print(f"Error: Not a valid ObjectId: {userID}")

    def get_all_gardens(self):
        gardens = self.gardens.find({})
        return gardens
    
    def add_garden(self, name, description, imageUrl, address, city, state, zipcode, userIDs):
        garden = {"name": name,
                  "description": description,
                  "imageUrl": imageUrl,
                  #"location": location
                  "address": address,
                  "city": city,
                  "state": state,
                  "zipcode": zipcode,
                  "userIDs": userIDs}
        # Sanitize input
        garden = self.sanitize_input(garden)
        self.gardens.insert_one(garden)
        # Find all userIDs and add the gardenID to their list of gardens
        for userID in userIDs:
            try:
                userID = ObjectId(userID)
                self.users.update_one(
                    {"_id": userID},
                    {"$push": {"gardenIDs": garden["_id"]}}
                )
            except Exception:
                print(f"Error: Not a valid ObjectId: {userID}")

        id = self.gardens.find_one({"name": name})["_id"]
        return id
    
    def update_garden(self, gardenID, name, description, imageUrl, address, city, state, zipcode, userIDs):
        garden = {"name": name,
                  "description": description,
                  "imageUrl": imageUrl,
                  "address": address,
                  "city": city,
                  "state": state,
                  "zipcode": zipcode}
        garden = self.sanitize_input(garden)
        self.gardens.update_one(
            {"_id": ObjectId(gardenID)},
            {"$set": {**garden}}
        )

    def delete_garden(self, gardenID):
        self.gardens.delete_one({"_id": ObjectId(gardenID)})

    def delete_all(self):
        self.plants.delete_many({})
        self.users.delete_many({})
        self.comments.delete_many({})
        self.gardens.delete_many({})

    def sanitize_input(data: dict) -> dict:
        clean = {}
        for key, value in data.items():
            # Disallow keys with $ or . (NoSQL injection risk)
            if key.startswith('$') or '.' in key:
                continue
            if isinstance(value, str):
                value = value.strip()
            clean[key] = value
        return clean


class Gardens(Document):
    name = StringField(required=True)
    description = StringField()
    imageUrl = StringField()
    # location = StringField()
    address = StringField()
    city = StringField()
    state = StringField()
    zipcode = StringField()

    meta = {
        'indexes': [
            {'fields': ['$name'], 'default_language': 'english'},  # for search
            {'fields': ['city', 'state']},  # for searching by city
            {'fields': ['zipcode']}
        ]
    }

class Plants(Document):
    gardenID = ReferenceField(Gardens, reverse_delete_rule=4)
    name = StringField(required=True)
    imageUrl = StringField()
    description = StringField()

    # # index for names
    # meta = {
    #     'indexes': [
    #         {'fields': ['$name'], 'default_language': 'english'},  # for search
    #         {'fields': ['gardenID']},  # for searching by gardenID
    #     ]
    # }

if __name__ == '__main__':
    db = Database()
    # plants = db.get_all_plants()
    # print(plants[0])
    db.delete_all()

    userID1 = db.add_user(username="jeffrey",
                          name="Jeffrey Wu",
                          email="wu.jeffrey.j@gmail.com",
                          phoneNumber="510-396-8282",
                          profilePicUrl="jeffrey.jpg",
                          biography="A passionate gardener with a love for spices.",
                          gardenIDs=[])

    userID2 = db.add_user(username="molly",
                          name="Molly Brown",
                          email="molly.brown@hotmail.com",
                          phoneNumber="123-456-7890",
                          profilePicUrl="molly.jpg",
                          biography="A flower enthusiast with a green thumb.",
                          gardenIDs=[])

    userID3 = db.add_user(username="mike",
                            name="Mike Tyson",
                            email="mike.tyson@gmail.com",
                            phoneNumber="987-654-3210",
                            profilePicUrl="mike.jpg",
                            biography="A boxing champion with a love for gardening.",
                            gardenIDs=[])

    userID4 = db.add_user(username="sus",
                            name="Susan B. Anthony",
                            email="susan.b.anthony@hotmail.com",
                            phoneNumber="123-456-7890",
                            profilePicUrl="susan.jpg",
                            biography="A passionate gardener and activist.",
                            gardenIDs=[])

    gardenID1 = db.add_garden(name="Jeff's Garden",
                              description="Every spice you need!",
                              imageUrl="jeff's_garden.jpg",
                              address="123 Spice St",
                              city="New York",
                              state="NY",
                              zipcode="10001",
                              userIDs=[userID1, userID2])
                                                          
                              
    gardenID2 = db.add_garden(name="1800-Flowers",
                              description="A beautiful garden of flowers",
                              imageUrl="1800-flowers.jpg", 
                              address="456 Flower St",
                              city="Los Angeles",
                              state="CA",
                              zipcode="90001",
                              userIDs=["jeffrey", "molly"])

    db.add_plant(gardenID=gardenID1, name="Rosemary", imageUrl="rosemary.jpg", description="A fragrant herb used in cooking.")
    db.add_plant(gardenID=gardenID1, name="Thyme", imageUrl="thyme.jpg", description="A versatile herb with a strong flavor.")
    db.add_plant(gardenID=gardenID1, name="Cherry Tree", imageUrl="cherry_tree.jpg", description="A tree that produces sweet cherries.")
    db.add_plant(gardenID=gardenID1, name="Indica Flower", imageUrl="indica_flower.jpg", description="A flowering plant known for its relaxing properties.")
    db.add_plant(gardenID=gardenID1, name="Saffron", imageUrl="saffron.jpg", description="A spice derived from the flower of Crocus sativus.")

    db.add_plant(gardenID=gardenID2, name="Tulip", imageUrl="tulip.jpg", description="A bulbous spring perennial flower.")
    db.add_plant(gardenID=gardenID2, name="Daisy", imageUrl="daisy.jpg", description="A common flowering plant with white petals and a yellow center.")
    db.add_plant(gardenID=gardenID2, name="Rose", imageUrl="rose.jpg", description="A woody perennial flowering plant of the genus Rosa.")
    db.add_plant(gardenID=gardenID2, name="Lily", imageUrl="lily.jpg", description="A flowering plant with large, prominent flowers.")
    db.add_plant(gardenID=gardenID2, name="Daffodil", imageUrl="daffodil.jpg", description="A spring perennial flower with a trumpet-shaped structure.")

    load_dotenv()
    mongo_orm_uri = os.getenv("MONGO_ORM_URI")
    connect(host=mongo_orm_uri)

    garden3 = Gardens(name="Italian Heaven",
                      description="A collection of miniature trees.",
                      imageUrl="italian_heaven.jpg", 
                      address="789 Italian St",
                      city="Chicago",
                      state="IL",
                      zipcode="60601",
                      userIDs=["mike", "molly"])
    garden3.save()

    tomato = Plants(gardenID=garden3, name="Tomato", imageUrl="tomato.jpg", description="A red fruit used in salads and sauces.")
    basil = Plants(gardenID=garden3, name="Basil", imageUrl="basil.jpg", description="A fragrant herb used in cooking.")
    mint = Plants(gardenID=garden3, name="Mint", imageUrl="mint.jpg", description="A refreshing herb used in drinks and desserts.")
    garlic = Plants(gardenID=garden3, name="Garlic", imageUrl="garlic.jpg", description="A pungent bulb used in cooking.")
    onion = Plants(gardenID=garden3, name="Onion", imageUrl="onion.jpg", description="A bulbous vegetable used in cooking.")

    tomato.save()
    basil.save()
    mint.save()
    garlic.save()
    onion.save()

    garden4 = Gardens(name="Cactus Garden",
                      description="A collection of desert plants.",
                      imageUrl="cactus_garden.png",
                      address="101 Desert St",
                      city="Phoenix",
                      state="AZ",
                      zipcode="85001",
                      userIDs=["sus", "molly"])
    garden4.save()

    cactus = Plants(gardenID=garden4, name="Cactus", imageUrl="cactus.jpg", description="A succulent plant adapted to arid environments.")
    aloe_vera = Plants(gardenID=garden4, name="Aloe Vera", imageUrl="aloe_vera.jpg", description="A succulent plant known for its medicinal properties.")
    agave = Plants(gardenID=garden4, name="Agave", imageUrl="agave.jpg", description="A succulent plant used to make tequila.")
    prickly_pear = Plants(gardenID=garden4, name="Prickly Pear", imageUrl="prickly_pear.jpg", description="A cactus with edible fruit.")
    yucca = Plants(gardenID=garden4, name="Yucca", imageUrl="yucca.jpg", description="A plant with sword-like leaves and edible roots.")

    cactus.save()
    aloe_vera.save()
    agave.save()
    prickly_pear.save()
    yucca.save()

    db.index_plant()

    # Find a garden
    garden = Gardens.objects(name="Cactus Garden").first()

    # Get all plants in that garden
    plants = Plants.objects(gardenID=garden)

    for plant in plants:
        print(plant.name, plant.imageUrl, plant.description)

    plants = db.plants.find({"gardenID": gardenID1})
    for plant in plants:
        print(plant["name"], plant["imageUrl"], plant["description"])

    explanation = db.plants.find({ "gardenID": gardenID1 }).explain()

    import pprint
    pprint.pprint(explanation)
    # db.delete_plant("Tree")