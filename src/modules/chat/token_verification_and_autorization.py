from flask import Flask, request, jsonify
import sqlite3
import requests
import jwt
from functools import wraps
from werkzeug.security import check_password_hash
from datetime import datetime, timedelta

app = Flask(__name__)

# Configuration - UPDATED to match login_jwt.py
CHAT_DATABASE = 'chat.db'
USER_API_URL = 'http://localhost:5000'  # User registration API URL
AUTH_API_URL = 'http://localhost:3000'  # Authentication API URL
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Must match login_jwt.py

def token_required(f):
    """Decorator to verify JWT token - Updated to match login_jwt.py"""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return jsonify({'error': 'Authorization header is missing'}), 401

        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Authorization header must start with Bearer'}), 401

        try:
            # Extract token from Bearer header
            token = auth_header[7:]  # Remove 'Bearer ' prefix

            # Decode JWT token with matching secret key and algorithm
            payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            
            current_user = {
                'user_id': payload['user_id'],
                'username': payload['username']
            }
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token is invalid'}), 401
        except KeyError as e:
            return jsonify({'error': f'Token missing required field: {str(e)}'}), 401

        return f(current_user, *args, **kwargs)

    return decorated
