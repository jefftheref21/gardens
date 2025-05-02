from flask import Flask, request
# from bson import Objectid
from database import Database
import json

# class JSONEncoder(json.JSONEncoder):
#     def default(self, obj):
#         if isinstance(obj, objectid.ObjectId):
#             return str(obj)
#         return super(JSONEncoder, self).default(obj)

app = Flask(__name__)
# app.json_encoder = JSONEncoder
db = Database()

@app.route('/home', methods=['GET'])
def home():
    db_gardens = db.get_all_gardens()
    gardens = list(db_gardens)
    for garden in gardens:
        garden['_id'] = str(garden['_id'])
    print(gardens)
    return {"gardens": gardens}, 200

@app.route('/garden/<gardenID>', methods=['GET'])
def get_plants(gardenID):
    db_plants = db.get_all_plants_by_gardenID(gardenID)
    plants = list(db_plants)
    for plant in plants:
        plant['_id'] = str(plant['_id'])
        plant['gardenID'] = str(plant['gardenID'])
    print(plants)
    return {"plants": plants}, 200

@app.route('/garden/<gardenID>', methods=['POST'])
def add(gardenID):
    name = request.json['name']
    imageUrl = request.json['imageUrl']
    description = request.json['description']
    print (name, imageUrl)
    id = db.add_plant(gardenID, name, imageUrl, description)
    id = str(id)
    return {"plantID": id, "message": "Plant added"}, 200

@app.route('/garden', methods=['PUT'])
def update():
    plant_id = request.json['plantID']
    name = request.json['name']
    imageUrl = request.json['imageUrl']
    description = request.json['description']
    db.update_plant(plant_id, name, imageUrl, description)
    return {"message": "Plant updated"}, 200

@app.route('/garden', methods=['DELETE'])
def delete():
    plant_id = request.json['plantID']
    db.delete_plant(plant_id)
    return {"message": "Plant deleted"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
