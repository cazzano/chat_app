from flask import Flask, request, jsonify, Blueprint
import sqlite3
import requests
import jwt
from functools import wraps
from werkzeug.security import check_password_hash
from datetime import datetime, timedelta
from modules.chat.token_verification_and_autorization import token_required
from modules.chat.init_friends_db import init_friends_db
from modules.chat.init_request_db import init_friend_requests_db
from modules.chat.remove_friendship import remove_friendship
from modules.chat.get_user_friends import get_user_friends
from modules.chat.get_user_by_username import get_user_by_username
from modules.chat.add_friendship import add_friendship
from modules.chat.check_existing_friend_request import check_existing_friend_request
from modules.chat.check_if_already_friends import check_if_already_friends
from modules.chat.get_user_by_userid import get_username_by_user_id

# Configuration - Updated to match login_jwt.py
CHAT_DATABASE = 'chat.db'
FR_REQUESTS_DATABASE = 'fr_requests.db'
FRIENDS_DATABASE = 'friends.db'
DATABASE = 'users.db'  # Same as login_jwt.py
USER_API_URL = 'http://localhost:5000'  # User registration API URL
AUTH_API_URL = 'http://localhost:3000'  # Authentication API URL
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Should match login_jwt.py

get_friends = Blueprint('get_friends', __name__)

def get_db():
    """Get database connection - matching login_jwt.py"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def init_friends_db():
    """Initialize the friends database"""
    try:
        conn = sqlite3.connect(FRIENDS_DATABASE)
        cursor = conn.cursor()

        # Create friends table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS friends (
                friendship_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user1_id TEXT NOT NULL,
                user1_username TEXT NOT NULL,
                user2_id TEXT NOT NULL,
                user2_username TEXT NOT NULL,
                friendship_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user1_id) REFERENCES users(user_id),
                FOREIGN KEY (user2_id) REFERENCES users(user_id),
                UNIQUE(user1_id, user2_id),
                UNIQUE(user2_id, user1_id)
            )
        ''')

        conn.commit()
        conn.close()
        print("Friends database initialized successfully")

    except Exception as e:
        print(f"Error initializing friends database: {e}")

@get_friends.route('/auth/get_friends', methods=['GET'])
@token_required
def get_friends_auth(current_user):
    """Get all friends for the authenticated user
    
    Usage with JWT token from login_jwt.py:
    Headers: Authorization: Bearer <your_jwt_token_from_login>
    """
    try:
        user_id = current_user['user_id']
        
        # Get current user's username using the same database as login_jwt.py
        try:
            with get_db() as conn:
                cursor = conn.execute('SELECT username FROM users WHERE user_id = ?', (user_id,))
                user_row = cursor.fetchone()
                if not user_row:
                    return jsonify({
                        'error': 'Current user not found in database'
                    }), 404
                username = user_row['username']
        except Exception as e:
            return jsonify({
                'error': f'Failed to get current user info: {str(e)}'
            }), 500

        # Initialize friends database
        init_friends_db()

        # Get user's friends
        friends = get_user_friends(user_id)

        # Enhanced friend information with additional details
        enhanced_friends = []
        for friend in friends:
            # Get additional user info from main users database
            try:
                with get_db() as conn:
                    cursor = conn.execute('''
                        SELECT username, user_id 
                        FROM users 
                        WHERE user_id = ?
                    ''', (friend['friend_id'],))
                    friend_user = cursor.fetchone()
                    
                    if friend_user:
                        enhanced_friends.append({
                            'friendship_id': friend['friendship_id'],
                            'friend_id': friend['friend_id'],
                            'friend_username': friend_user['username'],  # Get from main DB for consistency
                            'friendship_date': friend['friendship_date'],
                            'status': 'active'
                        })
            except Exception as e:
                # Fallback to original data if main DB lookup fails
                enhanced_friends.append({
                    'friendship_id': friend['friendship_id'],
                    'friend_id': friend['friend_id'],
                    'friend_username': friend['friend_username'],
                    'friendship_date': friend['friendship_date'],
                    'status': 'active'
                })

        # Sort friends by most recent first
        enhanced_friends.sort(key=lambda x: x['friendship_date'], reverse=True)

        return jsonify({
            'success': True,
            'user_info': {
                'user_id': user_id,
                'username': username
            },
            'friends': enhanced_friends,
            'total_friends': len(enhanced_friends),
            'timestamp': datetime.utcnow().isoformat()
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Failed to get friends: {str(e)}'
        }), 500

@get_friends.route('/auth/get_friends_count', methods=['GET'])
@token_required
def get_friends_count(current_user):
    """Get total friends count for the authenticated user
    
    Usage with JWT token from login_jwt.py:
    Headers: Authorization: Bearer <your_jwt_token_from_login>
    """
    try:
        user_id = current_user['user_id']
        
        # Get current user's username using the same database as login_jwt.py
        try:
            with get_db() as conn:
                cursor = conn.execute('SELECT username FROM users WHERE user_id = ?', (user_id,))
                user_row = cursor.fetchone()
                if not user_row:
                    return jsonify({
                        'error': 'Current user not found in database'
                    }), 404
                username = user_row['username']
        except Exception as e:
            return jsonify({
                'error': f'Failed to get current user info: {str(e)}'
            }), 500

        # Initialize friends database
        init_friends_db()

        # Get user's friends count
        friends = get_user_friends(user_id)
        friends_count = len(friends)

        return jsonify({
            'success': True,
            'user_info': {
                'user_id': user_id,
                'username': username
            },
            'total_friends': friends_count,
            'timestamp': datetime.utcnow().isoformat()
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Failed to get friends count: {str(e)}'
        }), 500

@get_friends.route('/auth/check_friendship/<friend_username>', methods=['GET'])
@token_required
def check_friendship_status(current_user, friend_username):
    """Check if you are friends with a specific user
    
    Usage with JWT token from login_jwt.py:
    Headers: Authorization: Bearer <your_jwt_token_from_login>
    URL: /auth/check_friendship/friend_username
    """
    try:
        user_id = current_user['user_id']
        
        # Get friend's user_id by username using the same database as login_jwt.py
        try:
            with get_db() as conn:
                cursor = conn.execute('SELECT user_id FROM users WHERE username = ?', (friend_username,))
                friend_row = cursor.fetchone()
                if not friend_row:
                    return jsonify({
                        'success': False,
                        'error': f'User "{friend_username}" not found'
                    }), 404
                friend_user_id = friend_row['user_id']
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f'Failed to get friend info: {str(e)}'
            }), 500

        # Check if they are friends
        are_friends = check_if_already_friends(user_id, friend_user_id)

        return jsonify({
            'success': True,
            'user_info': {
                'user_id': user_id,
                'username': current_user['username']
            },
            'friend_info': {
                'user_id': friend_user_id,
                'username': friend_username
            },
            'are_friends': are_friends,
            'timestamp': datetime.utcnow().isoformat()
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Failed to check friendship status: {str(e)}'
        }), 500
