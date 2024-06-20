from __future__ import absolute_import
from flask import Flask, request, jsonify
import cv2
from deepface import DeepFace
import os
import asyncio
from celery import Celery
import tensorflow as tf
import concurrent.futures

app = Flask(__name__)
celery = Celery(app.name, broker='amqp://guest@localhost//')

# Banco de dados simulado para pessoas cadastradas
pessoas_cadastradas = [
    {'nome': 'Brad Pitt', 'img_ref': 'known_faces/pitt.jpg', 'status': 'morador'},
    {'nome': 'Jason Momoa', 'img_ref': 'known_faces/momoa.jpg', 'status': 'conhecido'}
]

@app.route('/register', methods=['POST'])
def register_person():
    data = request.form
    nome = data.get('nome')
    status = data.get('status')
    img = request.files['img']

    if nome and status and img:
        img_path = os.path.join('known_faces', img.filename)
        img.save(img_path)

        pessoas_cadastradas.append({
            'nome': nome,
            'img_ref': img_path,
            'status': status
        })

        return jsonify({"message": "Pessoa registrada com sucesso!"}), 201
    else:
        return jsonify({"message": "Dados incompletos"}), 400
    

@celery.task
def recognize_person(img_path):
    # Ensure TensorFlow uses the GPU
    tf.config.experimental.set_memory_growth(True)
    tf.config.experimental.set_virtual_device_configuration(
        tf.config.experimental.VirtualDeviceConfiguration(
            memory_limit=4096  # Adjust the memory limit as needed
        )
    )

    # Perform GPU-accelerated task here
    with tf.device('/gpu:0'):  # Specify the GPU device
        result = DeepFace.verify(img1_path=pessoa['img_ref'], img2_path=img_path)
    return result

@app.route('/recognize', methods=['POST'])
def recognize_person_view():
    if 'img' not in request.files:
        return jsonify({"message": "Imagem não encontrada no request"}), 400

    img = request.files['img']
    input_img_path = os.path.join('input_imgs', img.filename)
    img.save(input_img_path)

    recognized_person = None

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        futures = []
        for pessoa in pessoas_cadastradas:
            future = executor.submit(DeepFace.verify, img1_path=pessoa['img_ref'], img2_path=input_img_path)
            futures.append(future)

        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result['verified']:
                recognized_person = pessoa
                break

    if recognized_person:
        return jsonify({
            "nome": recognized_person['nome'],
            "status": recognized_person['status']
        }), 200
    else:
        return jsonify({
            "nome": "",
            "status": "desconhecido"
        }), 200

if __name__ == '__main__':
    os.makedirs('known_faces', exist_ok=True)
    os.makedirs('input_imgs', exist_ok=True)
    asyncio.run(app.run(host='0.0.0.0', port=5000, threaded=True, processes=1))
