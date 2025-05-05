from pymongo import MongoClient
from mongoengine import Document, StringField, FloatField, ListField, ReferenceField, DateTimeField, connect
from bson import ObjectId
from dotenv import load_dotenv
import os
import certifi

ca = certifi.where()
class DatabaseQueries():
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

    def add_plant(self, gardenID, name, imageUrl, description, age=None):
        plant = {"gardenID": ObjectId(gardenID),
                 "name": name,
                 "imageUrl": imageUrl,
                 "description": description}
        if age:
            plant["age"] = age
        # Sanitize input
        plant = self.sanitize_input(plant)
        result = self.plants.insert_one(plant)
        return result.inserted_id

    def update_plant(self, plantID, name, imageUrl, description, age):
        plant = {"name": name,
                 "imageUrl": imageUrl,
                 "description": description}
        # Sanitize input
        plant = self.sanitize_input(plant)
        try:
            plantID = ObjectId(plantID)
            self.plants.update_one(
                {"_id": plantID},
                {"$set": {"name": name, "imageUrl": imageUrl, "description": description, "age": age}}
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
        self.plants.create_index([("gardenID", 1)], name='plants_in_garden_index')
        self.plants.create_index([("name", 1)], name='plant_name_index')

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
    
    def filter_gardens(self, name=None, city=None, state=None, zipcode=None) -> tuple:
        query = {}
        if name:
            query["name"] = {"$regex": name, "$options": "i"}
        if city:
            query["city"] = {"$regex": city, "$options": "i"}
        if state:
            query["state"] = {"$regex": state, "$options": "i"}
        if zipcode:
            query["zipcode"] = {"$regex": zipcode, "$options": "i"}
            
        gardens = self.gardens.find(query)

        if not gardens:
            return gardens, None

        pipeline = [
            {"$match": query},
            {"$lookup": {
                "from": "plants",
                "localField": "_id",
                "foreignField": "gardenID",
                "as": "plants"
                }
            },
            {"$group": {
                "_id": None,
                "averageRating": {"$avg": "$rating"},
                "averagePlantsPerGarden": {"$avg": {"$size": "$plants"}},
                "averagePlantAge": {"$avg": {"$avg": "$plants.age"}},
            }
             }
        ]
        overall_stats = list(self.gardens.aggregate(pipeline))
        # Get rid of cursor
        if overall_stats:
            overall_stats = overall_stats[0]
        else:
            overall_stats = None
        return gardens, overall_stats
    
    def add_garden(self, name, description, imageUrl, address, city, state, zipcode, rating, userIDs):
        garden = {"name": name,
                  "description": description,
                  "imageUrl": imageUrl,
                  #"location": location
                  "address": address,
                  "city": city,
                  "state": state,
                  "zipcode": zipcode,
                  "rating": rating,
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
    
    def update_garden(self, gardenID, name, description, imageUrl, address, city, state, zipcode):
        garden = {"name": name,
                  "description": description,
                  "imageUrl": imageUrl,
                  "address": address,
                  "city": city,
                  "state": state,
                  "zipcode": zipcode}
        garden = self.sanitize_input(garden)
        try:
            gardenID = ObjectId(gardenID)
            self.gardens.update_one(
                {"_id": gardenID},
                {"$set": {**garden}}
            )
        except Exception:
            print(f"Error: Not a valid ObjectId: {gardenID}")
            return None
        

    def delete_garden(self, gardenID):
        try: 
            gardenID = ObjectId(gardenID)
            # Remove the gardenID from all users
            self.users.update_many(
                {"gardenIDs": gardenID},
                {"$pull": {"gardenIDs": gardenID}}
            )
            self.gardens.delete_one({"_id": gardenID})
        except Exception:
            print(f"Error: Not a valid ObjectId: {gardenID}")

    def delete_all(self):
        self.plants.drop_indexes()
        self.users.drop_indexes()
        self.comments.drop_indexes()
        self.gardens.drop_indexes()

        self.plants.delete_many({})
        self.users.delete_many({})
        self.comments.delete_many({})
        self.gardens.delete_many({})

    def sanitize_input(self, data: dict) -> dict:
        clean = {}
        for key, value in data.items():
            # Disallow keys with $ or . (NoSQL injection risk)
            if key.startswith('$') or '.' in key:
                continue
            if isinstance(value, str):
                value = value.strip()
            clean[key] = value
        return clean
    
class DatabaseODM():
    def __init__(self) -> None:
        load_dotenv()
        MONGO_ORM_URI = os.getenv("MONGO_ORM_URI")
        connect(db="gardens", host=MONGO_ORM_URI)
    
    def get_all_plants(self):
        plants = Plants.objects()
        return plants
    
    def add_plant(self, gardenID, name, imageUrl: str, description: str, age: int):
        plant = Plants(gardenID=gardenID, name=name, imageUrl=imageUrl, description=description, age=age)
        plant.save()
        return plant.id
    
    def add_user(self, username, name, email, phoneNumber, profilePicUrl, biography, gardenIDs):
        user = Users(username=username,
                     name=name,
                     email=email,
                     phoneNumber=phoneNumber,
                     profilePicUrl=profilePicUrl,
                     biography=biography,
                     gardenIDs=gardenIDs)
        user.save()
        return user.id
    
    def add_garden(self, name, description, imageUrl, address, city, state, zipcode, rating: float, userIDs):
        garden = Gardens(name=name,
                         description=description,
                         imageUrl=imageUrl,
                         address=address,
                         city=city,
                         state=state,
                         zipcode=zipcode,
                         rating=rating,
                         userIDs=userIDs)
        garden.save()

        # Add the gardenID to all users
        for userID in userIDs:
            user = Users.objects(id=userID).first()
            if user:
                user.gardenIDs.append(garden.id)
                user.save()
        return garden.id

class Users(Document):
    username = StringField(required=True, unique=True)
    name = StringField(required=True)
    email = StringField(required=True, unique=True)
    phoneNumber = StringField()
    profilePicUrl = StringField()
    biography = StringField()
    gardenIDs = ListField(ReferenceField('Gardens'))

    meta = {
        'indexes': [
            {'fields': ['$username'], 'default_language': 'english'},  # for search
            {'fields': ['name']},  # for searching by name
        ]
    }

class Gardens(Document):
    name = StringField(required=True)
    description = StringField()
    imageUrl = StringField()
    # location = StringField()
    address = StringField()
    city = StringField()
    state = StringField()
    zipcode = StringField()
    rating = FloatField()
    userIDs = ListField(ReferenceField(Users))    

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
    age = FloatField()

    meta = {
        'indexes': [
            {'fields': ['$name'], 'default_language': 'english'},  # for search
            {'fields': ['gardenID']},  # for searching by gardenID
        ]
    }

if __name__ == '__main__':
    dbq = DatabaseQueries()
    dbodm = DatabaseODM()
    # plants = db.get_all_plants()
    # print(plants[0])
    dbq.delete_all()

    userID1 = dbq.add_user(username="jeffrey",
                          name="Jeffrey Wu",
                          email="wu.jeffrey.j@gmail.com",
                          phoneNumber="510-396-8282",
                          profilePicUrl="jeffrey.jpg",
                          biography="A passionate gardener with a love for spices.",
                          gardenIDs=[])

    userID2 = dbq.add_user(username="molly",
                          name="Molly Brown",
                          email="molly.brown@hotmail.com",
                          phoneNumber="123-456-7890",
                          profilePicUrl="molly.jpg",
                          biography="A flower enthusiast with a green thumb.",
                          gardenIDs=[])

    userID3 = dbodm.add_user(username="mike",
                           name="Mike Tyson",
                           email="mike.tyson@gmail.com",
                           phoneNumber="987-654-3210",
                           profilePicUrl="mike.jpg",
                           biography="A boxing champion with a love for gardening.",
                           gardenIDs=[])

    userID4 = dbodm.add_user(username="sus",
                           name="Susan B. Anthony",
                           email="susan.b.anthony@hotmail.com",
                           phoneNumber="123-456-7890",
                           profilePicUrl="susan.jpg",
                           biography="A passionate gardener and activist.",
                           gardenIDs=[])

    gardenID1 = dbq.add_garden(name="Jeff's Garden",
                              description="Every spice you need!",
                              imageUrl="jeff's_garden.jpg",
                              address="123 Spice St",
                              city="New York",
                              state="NY",
                              zipcode="10001",
                              rating=4.8,
                              userIDs=[userID1, userID2])
                                                          
                              
    gardenID2 = dbq.add_garden(name="1800-Flowers",
                              description="A beautiful garden of flowers",
                              imageUrl="1800-flowers.jpg", 
                              address="456 Flower St",
                              city="Los Angeles",
                              state="CA",
                              zipcode="90001",
                              rating=4.5,
                              userIDs=[userID2, userID3])

    dbq.add_plant(gardenID=gardenID1, name="Rosemary", imageUrl="rosemary.jpg", description="A fragrant herb used in cooking.", age=0.5)
    dbq.add_plant(gardenID=gardenID1, name="Thyme", imageUrl="thyme.jpg", description="A versatile herb with a strong flavor.", age=0.3)
    dbq.add_plant(gardenID=gardenID1, name="Cherry Tree", imageUrl="cherry_tree.jpg", description="A tree that produces sweet cherries.", age=24.0)
    dbq.add_plant(gardenID=gardenID1, name="Indica Flower", imageUrl="indica_flower.jpg", description="A flowering plant known for its relaxing properties.", age=0.5)
    dbq.add_plant(gardenID=gardenID1, name="Saffron", imageUrl="saffron.jpg", description="A spice derived from the flower of Crocus sativus.", age=0.3)

    dbq.add_plant(gardenID=gardenID2, name="Tulip", imageUrl="tulip.jpg", description="A bulbous spring perennial flower.", age=0.5)
    dbq.add_plant(gardenID=gardenID2, name="Daisy", imageUrl="daisy.jpg", description="A common flowering plant with white petals and a yellow center.", age=0.5)
    dbq.add_plant(gardenID=gardenID2, name="Rose", imageUrl="rose.jpg", description="A woody perennial flowering plant of the genus Rosa.", age=0.5)
    dbq.add_plant(gardenID=gardenID2, name="Lily", imageUrl="lily.jpg", description="A flowering plant with large, prominent flowers.", age=0.4)
    dbq.add_plant(gardenID=gardenID2, name="Daffodil", imageUrl="daffodil.jpg", description="A spring perennial flower with a trumpet-shaped structure.", age=0.3)

    garden3 = dbodm.add_garden(name="Italian Heaven",
                               description="A collection of miniature trees.",
                               imageUrl="italian_heaven.jpg", 
                               address="789 Italian St",
                               city="Chicago",
                               state="IL",
                               zipcode="60601",
                               rating=3.5,
                               userIDs=[userID1, userID2])

    tomato = dbodm.add_plant(gardenID=garden3, name="Tomato", imageUrl="tomato.jpg", description="A red fruit used in salads and sauces.", age=0.5)
    basil = dbodm.add_plant(gardenID=garden3, name="Basil", imageUrl="basil.jpg", description="A fragrant herb used in cooking.", age=0.5)
    mint = dbodm.add_plant(gardenID=garden3, name="Mint", imageUrl="mint.jpg", description="A refreshing herb used in drinks and desserts.", age=0.2)
    garlic = dbodm.add_plant(gardenID=garden3, name="Garlic", imageUrl="garlic.jpg", description="A pungent bulb used in cooking.", age=0.5)
    onion = dbodm.add_plant(gardenID=garden3, name="Onion", imageUrl="onion.jpg", description="A bulbous vegetable used in cooking.", age=1.2)

    garden4 = dbodm.add_garden(name="Cactus Garden",
                               description="A collection of desert plants.",
                               imageUrl="cactus_garden.jpg",
                               address="101 Desert St",
                               city="Phoenix",
                               state="AZ",
                               zipcode="85001",
                               rating=4.0,
                               userIDs=[userID3, userID4])

    cactus = dbodm.add_plant(gardenID=garden4, name="Cactus", imageUrl="cactus.jpg", description="A succulent plant adapted to arid environments.", age=1.4)
    aloe_vera = dbodm.add_plant(gardenID=garden4, name="Aloe Vera", imageUrl="aloe_vera.jpg", description="A succulent plant known for its medicinal properties.", age=0.5)
    agave = dbodm.add_plant(gardenID=garden4, name="Agave", imageUrl="agave.jpg", description="A succulent plant used to make tequila.", age=1.0)
    prickly_pear = dbodm.add_plant(gardenID=garden4, name="Prickly Pear", imageUrl="prickly_pear.jpg", description="A cactus with edible fruit.", age=0.6)
    yucca = dbodm.add_plant(gardenID=garden4, name="Yucca", imageUrl="yucca.jpg", description="A plant with sword-like leaves and edible roots.", age=0.8)

    dbq.index_plant()

    # Find a garden
    garden = Gardens.objects(name="Cactus Garden").first()

    # Get all plants in that garden
    plants = Plants.objects(gardenID=garden)

    for plant in plants:
        print(plant.name, plant.imageUrl, plant.description)

    plants = dbq.plants.find({"gardenID": gardenID1})
    for plant in plants:
        print(plant["name"], plant["imageUrl"], plant["description"])

    explanation = dbq.plants.find({ "gardenID": gardenID1 }).explain()

    import pprint
    pprint.pprint(explanation)

    gardens1, stats1 = dbq.filter_gardens(name="Jeff's")
    gardens2, stats2 = dbq.filter_gardens(city="Phoenix", state="AZ")
    gardens3, stats3 = dbq.filter_gardens(zipcode="10001")
    gardens4, stats4 = dbq.filter_gardens(name="Jeff's Garden", city="New York", state="NY", zipcode="10001")

    print("Gardens with name 'Jeff's':")
    for garden in gardens1:
        print(garden["name"], garden["city"], garden["state"], garden["zipcode"])
    print("Overall stats:")
    print("Average rating:", stats1[0]["averageRating"])
    print("Average number of plants:", stats1[0]["averageNumberOfPlants"])
    print("Average plant age:", stats1[0]["averagePlantAge"])

    print("Gardens in Phoenix, AZ:")
    for garden in gardens2:
        print(garden["name"], garden["city"], garden["state"], garden["zipcode"])
    print("Overall stats:")
    print("Average rating:", stats2[0]["averageRating"])
    print("Average number of plants:", stats2[0]["averageNumberOfPlants"])
    print("Average plant age:", stats2[0]["averagePlantAge"])

    print("Gardens in zipcode 10001:")
    for garden in gardens3:
        print(garden["name"], garden["city"], garden["state"], garden["zipcode"])
    print("Overall stats:")
    print("Average rating:", stats3[0]["averageRating"])
    print("Average number of plants:", stats3[0]["averageNumberOfPlants"])
    print("Average plant age:", stats3[0]["averagePlantAge"])

    # db.delete_plant("Tree")