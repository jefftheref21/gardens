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
def show():
    db_plants = db.get_all_plants()
    plants = list(db_plants)
    for plant in plants:
        plant['_id'] = str(plant['_id'])
    print(plants)
    return {"plants": plants}, 200

@app.route('/home', methods=['POST'])
def add():
    name = request.json['name']
    imageUrl = request.json['imageUrl']
    print (name, imageUrl)
    id = db.add_plant(name, imageUrl)
    id = str(id)
    return {"plantID": id, "message": "Plant added"}, 200

@app.route('/home', methods=['PUT'])
def update():
    plant_id = request.json['plantID']
    name = request.json['name']
    imageUrl = request.json['imageUrl']
    db.update_plant(plant_id, name, imageUrl)
    return {"message": "Plant updated"}, 200

@app.route('/home', methods=['DELETE'])
def delete():
    plant_id = request.json['plantID']
    db.delete_plant(plant_id)
    return {"message": "Plant deleted"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
