from flask import Flask, request
# from bson import Objectid
from database import DatabaseQueries
import json

# class JSONEncoder(json.JSONEncoder):
#     def default(self, obj):
#         if isinstance(obj, objectid.ObjectId):
#             return str(obj)
#         return super(JSONEncoder, self).default(obj)

app = Flask(__name__)
# app.json_encoder = JSONEncoder
dbq = DatabaseQueries()

@app.route('/home', methods=['GET'])
def home():
    db_gardens = dbq.get_all_gardens()
    gardens = list(db_gardens)
    for garden in gardens:
        garden['_id'] = str(garden['_id'])
        # Turn the userIDs to a list of strings
        garden['userIDs'] = list(map(str, garden['userIDs']))
    print(gardens)
    return {"gardens": gardens}, 200

@app.route('/garden/<gardenID>', methods=['GET'])
def get_plants(gardenID):
    db_plants = dbq.get_all_plants_by_gardenID(gardenID)
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
    id = dbq.add_plant(gardenID, name, imageUrl, description)
    id = str(id)
    return {"plantID": id, "message": "Plant added"}, 200

@app.route('/garden', methods=['PUT'])
def update():
    plant_id = request.json['plantID']
    name = request.json['name']
    imageUrl = request.json['imageUrl']
    description = request.json['description']
    dbq.update_plant(plant_id, name, imageUrl, description)
    return {"message": "Plant updated"}, 200

@app.route('/garden', methods=['DELETE'])
def delete():
    plant_id = request.json['plantID']
    dbq.delete_plant(plant_id)
    return {"message": "Plant deleted"}, 200

@app.route('/explore', methods=['GET'])
def explore():
    name = None
    city = None
    state = None
    zipcode = None
    if 'name' in request.args:
        name = request.args['name']
    if 'city' in request.args:
        city = request.args['city']
    if 'state' in request.args:
        state = request.args['state']
    if 'zipcode' in request.args:
        zipcode = request.args['zipcode']

    gardens, stats = dbq.filter_gardens(name, city, state, zipcode)
    gardens = list(gardens)
    for garden in gardens:
        garden['_id'] = str(garden['_id'])
        # Turn the userIDs to a list of strings
        garden['userIDs'] = list(map(str, garden['userIDs']))
    return {"gardens": gardens, "stats": stats, "message": "Filtered"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
